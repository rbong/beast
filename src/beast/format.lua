local function address_to_index(address)
    return (address % 0x4000) + 1
end

-- FileGenerator is used to track the current state of file generation and
-- handle file generation order.
local FileGenerator = {}

FileGenerator.new = function(self, base_path, rom, symbols, formatter)
    local file_generator = {
        base_path = base_path,
        rom = rom,
        rom_labels = formatter:format_rom_labels(rom, symbols),
        symbols = symbols,
        formatter = formatter,
    }

    setmetatable(file_generator, self)
    self.__index = self

    return file_generator
end

FileGenerator.open_files = function(self)
    self.main_file = io.open(self.formatter:get_main_file_path(self.base_path), "wb")
    self.memory_file = io.open(self.formatter:get_memory_file_path(self.base_path), "wb")
end

FileGenerator.close_files = function(self)
    if self.main_file ~= nil then
        self.main_file:close()
        self.main_file = nil
    end
    if self.memory_file ~= nil then
        self.memory_file:close()
        self.memory_file = nil
    end
end

FileGenerator.get_bank_start_address = function(self, bank_num)
    if bank_num == 0 then
        return 0x0000
    end
    return 0x4000
end

FileGenerator.get_bank_end_address = function(self, bank_num)
    if bank_num == 0 then
        return 0x4000
    end
    return 0x8000
end

FileGenerator.write_line_with_address = function(self, bank_num, address, file, line)
    file:write(line)

    file:write(" ")
    local len = #line
    while len < 60 do
        file:write(" ")
        len = len + 1
    end

    file:write(self.formatter:format_address(bank_num, address))
end

FileGenerator.generate_memory_symbols = function(self, memory_symbols, address)
    local labels = memory_symbols.labels
    local comments = memory_symbols.comments

    if comments[address] then
        for _, comment in pairs(comments[address]) do
            self.memory_file:write(self.formatter:format_comment(comment))
        end
    end

    for i, label in pairs(labels[address]) do
        if i == 0 and address ~= 0x0000 then
            self.memory_file:write("\n")
        end
        self.memory_file:write(self.formatter:format_label(label))
    end

    self.memory_file:write(self.formatter:format_memory_placeholder())
end

FileGenerator.generate_sram_memory_file_sections = function(self, has_memory_sections)
    -- TODO: get rid of table.maxn
    -- TODO: warn when not using LuaJIT
    local max_sram_bank = table.maxn(self.symbols.sram_banks)

    if max_sram_bank == nil then
        return has_memory_sections
    end

    for sram_bank_num = 0, max_sram_bank do
        local sram_symbols = self.symbols:get_init_sram_bank(sram_bank_num)
        local last_address = -2

        for address = 0xa000, 0xbfff do
            if sram_symbols.labels[address] then
                if last_address ~= address - 1 then
                    if has_memory_sections then
                        self.memory_file:write("\n")
                    end
                    self.memory_file:write(self.formatter:format_sram_section_header(sram_bank_num, address))
                end

                self:generate_memory_symbols(sram_symbols, address)

                has_memory_sections = true
                last_address = address
            end
        end
    end

    return has_memory_sections
end

FileGenerator.generate_wram_memory_file_sections = function(self, has_memory_sections)
    local max_wram_bank = table.maxn(self.symbols.wram_banks)

    if max_wram_bank == nil then
        return has_memory_sections
    end

    for wram_bank_num = 0, max_wram_bank do
        local wram_symbols = self.symbols:get_init_wram_bank(wram_bank_num)
        local last_address = -2

        local wram_address_start
        local wram_address_end

        if wram_bank_num == 0 then
            wram_address_start = 0xc000
            wram_address_end = 0xcfff
        else
            wram_address_start = 0xd000
            wram_address_end = 0xdfff
        end

        for address = wram_address_start, wram_address_end do
            if wram_symbols.labels[address] then
                if last_address ~= address - 1 then
                    if has_memory_sections then
                        self.memory_file:write("\n")
                    end
                    self.memory_file:write(self.formatter:format_wram_section_header(wram_bank_num, address))
                end

                self:generate_memory_symbols(wram_symbols, address)

                has_memory_sections = true
                last_address = address
            end
        end
    end

    return has_memory_sections
end

FileGenerator.generate_hram_memory_file_sections = function(self, has_memory_sections)
    local hram_symbols = self.symbols.hram

    local last_address = -2
    for address = 0xff80, 0xfffe do
        if hram_symbols.labels[address] then
            if last_address ~= address - 1 then
                if has_memory_sections then
                    self.memory_file:write("\n")
                end
                self.memory_file:write(self.formatter:format_hram_section_header(address))
            end

            self:generate_memory_symbols(hram_symbols, address)

            has_memory_sections = true
            last_address = address
        end
    end

    return has_memory_sections
end

FileGenerator.generate_memory_file = function(self)
    local has_sections = self:generate_sram_memory_file_sections(false)
    has_sections = self:generate_wram_memory_file_sections(has_sections)
    self:generate_hram_memory_file_sections(has_sections)

    self.main_file:write(self.formatter:format_include_statement(self.formatter:get_memory_file_name()))
end

FileGenerator.generate_include_files = function(self)
    for source_path, file_name, path in self.formatter:get_include_files(self.base_path) do
        local source_file = io.open(source_path, "rb")
        local file = io.open(path, "wb")

        file:write(source_file:read("a"))

        source_file:close()
        file:close()

        self.main_file:write(self.formatter:format_include_statement(file_name))
    end
end

FileGenerator.generate_file_symbol_file = function(self, bank_num, address, file_symbol)
    local path = self.formatter:get_file_symbol_file_path(self.base_path, file_symbol)
    local file = io.open(path, "wb")

    local index = address_to_index(address)

    file:write(self.rom.banks[bank_num].data:sub(index, index + file_symbol.size - 1))
    file:close()
end

FileGenerator.generate_bank_data = function(self, bank_num, address, bank_file)
    local bank = self.rom.banks[bank_num]
    local bank_symbols = self.symbols:get_init_rom_bank(bank_num)

    local instructions = bank.instructions
    local labels = self.rom_labels[bank_num]
    local comments = bank_symbols.comments
    local regions = bank_symbols.regions
    local files = bank_symbols.files

    local index = address_to_index(address)
    local end_address = self:get_bank_end_address(bank_num)
    local region = bank_symbols.regions[address] or {}
    local size = 0

    -- Get data size

    local check_address = address
    local check_index = index

    if region.region_type == "data" or region.region_type == "text" and region.size > 0 then
        -- Get data size for region: can only be terminated by end of bank or file
        repeat
            size = size + 1
            check_address = check_address + 1
            check_index = check_index + 1
        until check_index >= end_address or size >= region.size or files[check_address]
    else
        -- Get data size for plain data: can be terminated by instructions, new labels, comments, or regions
        repeat
            size = size + 1
            check_address = check_address + 1
            check_index = check_index + 1
        until check_index >= end_address
            or instructions[check_address]
            or labels[check_address]
            or comments[check_address]
            or regions[check_address]
            or files[check_address]
    end

    -- Write output

    if region.region_type == "text" then
        local line = self.formatter:format_text(self.rom, bank_num, address, size)
        self:write_line_with_address(bank_num, address, bank_file, line)
    else
        local remaining_bytes = size

        -- Output by increments of 8
        if remaining_bytes >= 8 then
            repeat
                local line = self.formatter:format_full_data_line(self.rom, bank_num, address)
                self:write_line_with_address(bank_num, address, bank_file, line)

                remaining_bytes = remaining_bytes - 8
                address = address + 8
                index = index + 8
            until remaining_bytes < 8
        end

        if remaining_bytes > 0 then
            local line = self.formatter:format_partial_data_line(self.rom, bank_num, address, remaining_bytes)
            self:write_line_with_address(bank_num, address, bank_file, line)
        end
    end

    return size
end

FileGenerator.generate_bank_file = function(self, bank_num)
    local bank = self.rom.banks[bank_num]
    local bank_symbols = self.symbols:get_init_rom_bank(bank_num)

    local file_name = self.formatter:get_bank_file_name(bank_num)
    local path = self.formatter:get_bank_file_path(self.base_path, bank_num)
    local file = io.open(path, "wb")

    self.main_file:write(self.formatter:format_include_statement(file_name))

    file:write(self.formatter:format_bank_header(bank_num))

    local address = self:get_bank_start_address(bank_num)
    local end_address = self:get_bank_end_address(bank_num)

    while address < end_address do
        -- Write labels
        local address_labels = self.rom_labels[bank_num][address]
        if address_labels then
            for i, label in pairs(address_labels) do
                if i == 1 and address % 0x4000 ~= 0x000 then
                    file:write("\n")
                end
                file:write(self.formatter:format_label(label))
            end
        end

        -- Write comments
        local address_comments = bank_symbols.comments[address]
        if address_comments then
            for _, comment in pairs(address_comments) do
                file:write(self.formatter:format_comment(comment))
            end
        end

        local replacement = bank_symbols.replacements[address]

        if replacement then
            -- Write replacement
            file:write(self.formatter:format_replacement(replacement.body))
            address = address + replacement.size
        else
            local file_symbol = bank_symbols.files[address]

            if file_symbol then
                -- Write file symbol
                self:generate_file_symbol_file(bank_num, address, file_symbol)
                local line = self.formatter:format_incbin_statement(file_symbol.file_name)
                self:write_line_with_address(bank_num, address, file, line)
                address = address + file_symbol.size
            else
                local instruction = bank.instructions[address]

                if instruction then
                    -- Write instruction
                    self:write_line_with_address(
                        bank_num,
                        address,
                        file,
                        self.formatter:format_instruction(self.rom, self.symbols, self.rom_labels, bank_num, address)
                    )
                    address = address + (instruction.size or 1)
                else
                    -- Write data
                    local size = self:generate_bank_data(bank_num, address, file)
                    address = address + size
                end
            end
        end
    end

    file:close()
end

FileGenerator.generate_files = function(self)
    self:close_files()
    self:open_files()

    self:generate_memory_file()
    self:generate_include_files()

    for bank_num = 0, self.rom.nbanks - 1 do
        self:generate_bank_file(bank_num)
    end

    self:close_files()
end

local Formatter = {}

Formatter.new = function(self, options)
    local formatter = {
        options = options,
    }

    setmetatable(formatter, self)
    self.__index = self

    local function get_byte_op_instruction_formatter(byte_format, op_format)
        return function(bank, address, symbols)
            local bank_num = bank.bank_num

            local op_symbol = symbols:get_init_rom_bank(bank_num).operands[address]
            if op_symbol then
                -- Format byte instruction with op symbol
                return string.format(op_format, op_symbol)
            end

            local data = bank.instructions[address].data

            -- Format byte instruction
            return string.format(byte_format, data)
        end
    end

    local function get_hram_op_instruction_formatter(byte_format, op_format)
        return function(bank, address, symbols)
            local bank_num = bank.bank_num

            local op_symbol = symbols:get_init_rom_bank(bank_num).operands[address]
            if op_symbol then
                -- Format HRAM instruction with op symbol
                return string.format(op_format, op_symbol)
            end

            -- Format HRAM instruction
            return string.format(byte_format, bank.instructions[address].data)
        end
    end

    local function get_octet_op_instruction_formatter(octet_format, op_format, label_format)
        if label_format == nil then
            label_format = op_format
        end

        return function(bank, address, symbols, rom_labels)
            local bank_num = bank.bank_num

            local op_symbol = symbols:get_init_rom_bank(bank_num).operands[address]
            if op_symbol then
                -- Format octet instruction with op symbol
                return string.format(op_format, op_symbol)
            end

            local data = bank.instructions[address].data

            local target_rom_labels
            if data >= 0x0150 and data < 0x4000 then
                target_rom_labels = rom_labels[0x00]
            else
                target_rom_labels = rom_labels[bank_num]
            end

            local label = target_rom_labels[data]
            if label then
                -- Format octet instruction with ROM label symbol
                return string.format(label_format, label[1])
            end

            local target_symbols = symbols:get_relative_memory_area(bank_num, data)
            if target_symbols then
                label = target_symbols.labels[data]
                if label then
                    -- Format octet instruction with label symbol
                    return string.format(label_format, label[1])
                end
            end

            -- Format octet instruction
            return string.format(octet_format, data)
        end
    end

    local function get_signed_op_instruction_formatter(signed_format, string_format, is_relative)
        return function(bank, address, symbols, rom_labels)
            local bank_num = bank.bank_num

            local bank_symbols = symbols:get_init_rom_bank(bank_num)
            local op_symbol = bank_symbols.operands[address]

            if op_symbol then
                -- Format signed instruction with op symbol
                return string.format(string_format, op_symbol)
            end

            local data = bank.instructions[address].data

            if is_relative then
                local label = rom_labels[bank_num][address + data + 2]

                if label then
                    return string.format(string_format, label[1])
                end

                -- Format relative signed instruction
                return string.format(signed_format, data + 2)
            end

            -- Format signed instruction
            return string.format(signed_format, data)
        end
    end

    self.instruction_formatters = {
        -- "ld" Instructions --

        ["ld a, n8"] = get_byte_op_instruction_formatter("ld a, $%02x", "ld a, %s"),
        ["ld b, n8"] = get_byte_op_instruction_formatter("ld b, $%02x", "ld b, %s"),
        ["ld c, n8"] = get_byte_op_instruction_formatter("ld c, $%02x", "ld c, %s"),
        ["ld d, n8"] = get_byte_op_instruction_formatter("ld d, $%02x", "ld d, %s"),
        ["ld e, n8"] = get_byte_op_instruction_formatter("ld e, $%02x", "ld e, %s"),
        ["ld h, n8"] = get_byte_op_instruction_formatter("ld h, $%02x", "ld h, %s"),
        ["ld l, n8"] = get_byte_op_instruction_formatter("ld l, $%02x", "ld l, %s"),

        ["ld a, [n16]"] = get_octet_op_instruction_formatter("ld a, [$%04x]", "ld a, [%s]"),
        ["ld [n16], a"] = get_octet_op_instruction_formatter("ld [$%04x], a", "ld [%s], a", "ld [%s], a"),

        ["ldio a, [$ff00+n8]"] = get_hram_op_instruction_formatter("ldio a, [$ff00+$%02x]", "ldio a, [%s]"),
        ["ldio [$ff00+n8], a"] = get_hram_op_instruction_formatter("ldio [$ff00+$%02x], a", "ldio [%s], a"),

        ["ld [hl], n8"] = get_octet_op_instruction_formatter("ld [hl], $%02x", "ld [hl], %s"),

        ["ld hl, n16"] = get_octet_op_instruction_formatter("ld hl, $%04x", "ld hl, %s"),
        ["ld bc, n16"] = get_octet_op_instruction_formatter("ld bc, $%04x", "ld bc, %s"),
        ["ld de, n16"] = get_octet_op_instruction_formatter("ld de, $%04x", "ld de, %s"),

        -- Arithmetic Instructions --

        ["add a, n8"] = get_byte_op_instruction_formatter("add a, $%02x", "add a, %s"),
        ["adc a, n8"] = get_byte_op_instruction_formatter("adc a, $%02x", "adc a, %s"),
        ["sub a, n8"] = get_byte_op_instruction_formatter("sub a, $%02x", "sub a, %s"),
        ["sbc a, n8"] = get_byte_op_instruction_formatter("sbc a, $%02x", "sbc a, %s"),
        ["and a, n8"] = get_byte_op_instruction_formatter("and a, $%02x", "and a, %s"),

        -- Logical Instructions --

        ["xor a, n8"] = get_byte_op_instruction_formatter("xor a, $%02x", "xor a, %s"),
        ["or a, n8"] = get_byte_op_instruction_formatter("or a, $%02x", "or a, %s"),
        ["cp a, n8"] = get_byte_op_instruction_formatter("cp a, $%02x", "cp a, %s"),

        -- Stack Instructions --

        ["add sp, e8"] = get_signed_op_instruction_formatter("add sp, %d", "add sp, %s"),
        ["ld hl, sp+e8"] = get_signed_op_instruction_formatter("ld hl, sp%+d", "ld hl, %s"),

        ["ld sp, n16"] = get_octet_op_instruction_formatter("ld sp, $%04x", "ld sp, %s"),
        ["ld [n16], sp"] = get_octet_op_instruction_formatter("ld [$%04x], sp", "ld [%s], sp", "ld [%s], sp"),

        -- Jump/Call Instructions --

        ["call n16"] = get_octet_op_instruction_formatter("call $%04x", "call %s"),
        ["call c, n16"] = get_octet_op_instruction_formatter("call c, $%04x", "call c, %s"),
        ["call z, n16"] = get_octet_op_instruction_formatter("call z, $%04x", "call z, %s"),
        ["call nc, n16"] = get_octet_op_instruction_formatter("call nc, $%04x", "call nc, %s"),
        ["call nz, n16"] = get_octet_op_instruction_formatter("call nz, $%04x", "call nz, %s"),

        ["jr e8"] = get_signed_op_instruction_formatter("jr @%+d", "jr %s", true),
        ["jr c, e8"] = get_signed_op_instruction_formatter("jr c, @%+d", "jr c, %s", true),
        ["jr z, e8"] = get_signed_op_instruction_formatter("jr z, @%+d", "jr z, %s", true),
        ["jr nc, e8"] = get_signed_op_instruction_formatter("jr nc, @%+d", "jr nc, %s", true),
        ["jr nz, e8"] = get_signed_op_instruction_formatter("jr nz, @%+d", "jr nz, %s", true),

        ["jp n16"] = get_octet_op_instruction_formatter("jp $%04x", "jp %s"),
        ["jp c, n16"] = get_octet_op_instruction_formatter("jp c, $%04x", "jp c, %s"),
        ["jp z, n16"] = get_octet_op_instruction_formatter("jp z, $%04x", "jp z, %s"),
        ["jp nc, n16"] = get_octet_op_instruction_formatter("jp nc, $%04x", "jp nc, %s"),
        ["jp nz, n16"] = get_octet_op_instruction_formatter("jp nz, $%04x", "jp nz, %s"),
    }

    return formatter
end

Formatter.get_main_file_name = function(self)
    return self.options.main
end

Formatter.get_main_file_path = function(self, base_path)
    return string.format("%s/%s", base_path, self:get_main_file_name())
end

Formatter.get_memory_file_name = function(self)
    return "memory.asm"
end

Formatter.get_memory_file_path = function(self, base_path)
    return string.format("%s/%s", base_path, self:get_memory_file_name())
end

Formatter.get_bank_file_name = function(self, bank_num)
    return string.format("bank_%03x.asm", bank_num)
end

Formatter.get_bank_file_path = function(self, base_path, bank_num)
    return string.format("%s/%s", base_path, self:get_bank_file_name(bank_num))
end

Formatter.get_file_symbol_file_path = function(self, base_path, file_symbol)
    return string.format("%s/%s", base_path, file_symbol.file_name)
end

Formatter.get_include_files = function(self, base_path)
    local i = 1

    return function()
        local source_path = self.options.include[i]

        if not source_path then
            return
        end

        local file_name = source_path:gsub(".*/", "")
        local path = string.format("%s/%s", base_path, file_name)

        i = i + 1

        return source_path, file_name, path
    end
end

Formatter.format_address = function(self, bank_num, address)
    return string.format("; %02x:%04x\n", bank_num, address)
end

Formatter.format_bank_header = function(self, bank_num)
    if bank_num == 0 then
        return 'SECTION "ROM Bank $000", ROM0[$0000]\n\n'
    end

    return string.format('SECTION "ROM Bank $%03x", ROMX[$4000], BANK[$%03x]\n\n', bank_num, bank_num)
end

Formatter.format_sram_section_header = function(self, bank_num, address)
    return string.format('SECTION "SRAM_%02x_%04x", SRAM[$%04x], BANK[$%02x]\n', bank_num, address, address, bank_num)
end

Formatter.format_wram_section_header = function(self, bank_num, address)
    if bank_num == 0 then
        return string.format('SECTION "WRAM_%02x_%04x", WRAM0[$%04x]\n', bank_num, address, address)
    end
    return string.format('SECTION "WRAM_%02x_%04x", WRAMX[$%04x], BANK[$%02x]\n', bank_num, address, address, bank_num)
end

Formatter.format_hram_section_header = function(self, address)
    return string.format('SECTION "HRAM_%04x", HRAM[$%04x]\n', address, address)
end

Formatter.format_label = function(self, label)
    return string.format("%s:\n", label)
end

Formatter.format_comment = function(self, comment)
    if comment == "" then
        return ";\n"
    end
    return string.format("; %s\n", comment)
end

Formatter.format_replacement = function(self, replacement)
    if replacement == "" then
        return "\n"
    end
    -- TODO: configurable indentation
    return string.format("    %s\n", replacement)
end

Formatter.format_include_statement = function(self, file_name)
    return string.format('INCLUDE "%s"\n', file_name)
end

Formatter.format_incbin_statement = function(self, file_name)
    -- TODO: configurable indentation
    return string.format('    INCBIN "%s"', file_name)
end

Formatter.format_memory_placeholder = function(self)
    -- TODO: configurable indentation
    return "    ds 1\n"
end

Formatter.format_rom_labels = function(self, rom, symbols)
    local labels = {}

    if self.options.no_auto_labels then
        for bank_num = 0, rom.nbanks - 1 do
            labels[bank_num] = symbols:get_init_rom_bank(bank_num).labels
        end
        return labels
    end

    local jump_locations = rom.jump_locations
    local relative_jump_locations = rom.relative_jump_locations
    local call_locations = rom.call_locations
    local rst_call_locations = rom.rst_call_locations

    for bank_num = 0, rom.nbanks - 1 do
        labels[bank_num] = {}

        local bank_jump_locations = jump_locations[bank_num]
        local bank_relative_jump_locations = relative_jump_locations[bank_num]
        local bank_call_locations = call_locations[bank_num]

        -- Format relative jump labels
        for address in pairs(bank_relative_jump_locations) do
            labels[bank_num][address] = { string.format("jr_%02x_%04x", bank_num, address) }
        end

        -- Format absolute jump labels
        -- Overwrites relative jump labels
        for address in pairs(bank_jump_locations) do
            if bank_relative_jump_locations[address] then
                labels[bank_num][address] = { string.format("jump_%02x_%04x", bank_num, address) }
            else
                labels[bank_num][address] = { string.format("jp_%02x_%04x", bank_num, address) }
            end
        end

        -- Format call labels
        -- Overwrites jump labels
        for address in pairs(bank_call_locations) do
            labels[bank_num][address] = { string.format("call_%02x_%04x", bank_num, address) }
        end

        -- Format RST labels
        -- Overwrites jump/call labels
        if bank_num == 0x00 then
            for address in pairs(rst_call_locations) do
                labels[0x00][address] = { string.format("rst_%02x", address) }
            end
        end

        -- Set manual labels
        -- Overwrites auto-generated labels
        for address, manual_labels in pairs(symbols:get_init_rom_bank(bank_num).labels) do
            labels[bank_num][address] = manual_labels
        end
    end

    return labels
end

Formatter.format_instruction = function(self, rom, symbols, rom_labels, bank_num, address)
    local bank = rom.banks[bank_num]
    local instruction = bank.instructions[address]

    local instruction_type = instruction.instruc

    if not instruction_type then
        -- TODO: better error handling
        error(string.format("Unrecognized instruction: %s", instruction.instruc))
    end

    local output
    local instruction_formatter = self.instruction_formatters[instruction_type]

    if instruction_formatter then
        -- Format complex instruction
        output = instruction_formatter(bank, address, symbols, rom_labels)
    else
        -- Format basic instruction
        output = instruction_type
    end

    -- TODO: configurable indentation
    return "    " .. output
end

Formatter.format_full_data_line = function(self, rom, bank_num, address)
    local data = rom.banks[bank_num].data
    local index = address_to_index(address)

    return string.format(
        -- TODO: configurable indentation
        "    db $%02x, $%02x, $%02x, $%02x, $%02x, $%02x, $%02x, $%02x",
        string.byte(data:sub(index, index)),
        string.byte(data:sub(index + 1, index + 1)),
        string.byte(data:sub(index + 2, index + 2)),
        string.byte(data:sub(index + 3, index + 3)),
        string.byte(data:sub(index + 4, index + 4)),
        string.byte(data:sub(index + 5, index + 5)),
        string.byte(data:sub(index + 6, index + 6)),
        string.byte(data:sub(index + 7, index + 7)),
        string.byte(data:sub(index + 8, index + 8))
    )
end

Formatter.format_partial_data_line = function(self, rom, bank_num, address, size)
    if size == 0 then
        return ""
    end

    local data = rom.banks[bank_num].data
    local index = address_to_index(address)

    -- TODO: configurable indentation
    local output = string.format("    db $%02x", string.byte(data:sub(index, index)))
    size = size - 1
    index = index + 1

    while size > 0 do
        output = output .. string.format(", $%02x", string.byte(data:sub(index, index)))
        size = size - 1
        index = index + 1
    end

    return output
end

Formatter.format_text = function(self, rom, bank_num, address, size)
    local data = rom.banks[bank_num].data

    local index = address_to_index(address)
    local end_index = index + size
    -- TODO: configurable indentation
    local output = "    db "

    local has_preceeding_byte = false
    local has_preceeding_char = false

    local escaped_chars = 0

    repeat
        local char = data:sub(index, index)
        local byte = string.byte(char)

        if (byte < 0x20 and char ~= "\t" and char ~= "\n") or byte == 0x7f then
            -- Handle non-printable bytes

            if has_preceeding_char then
                output = output .. '", '
            elseif has_preceeding_byte then
                output = output .. ", "
            end

            output = output .. string.format("$%02x", byte)
            has_preceeding_char = false
            has_preceeding_byte = true
        else
            -- Handle printable bytes

            if has_preceeding_byte then
                output = output .. ', "'
            elseif not has_preceeding_char then
                output = output .. '"'
            end

            if char == '"' or char == "\\" then
                -- Char which needs to be escaped
                output = output .. "\\" .. char
                escaped_chars = escaped_chars + 1
            elseif char == "\t" then
                -- Tab
                output = output .. "\\t"
                escaped_chars = escaped_chars + 1
            elseif char == "\n" then
                -- Newline
                output = output .. "\\n"
                escaped_chars = escaped_chars + 1
            else
                -- Other chars
                output = output .. char
            end

            has_preceeding_char = true
            has_preceeding_byte = false
        end

        index = index + 1
    until index >= end_index

    if has_preceeding_char then
        output = output .. '"'
    end

    return output
end

Formatter.generate_files = function(self, base_path, rom, symbols)
    local file_generator = FileGenerator:new(base_path, rom, symbols, self)
    file_generator:generate_files()
end

return {
    address_to_index = address_to_index,
    Formatter = Formatter,
    FileGenerator = FileGenerator,
}
