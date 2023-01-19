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

    return function(bank, address, symbols)
        local bank_num = bank.bank_num

        local op_symbol = symbols:get_init_rom_bank(bank_num).operands[address]
        if op_symbol then
            -- Format octet instruction with op symbol
            return string.format(op_format, op_symbol)
        end

        local data = bank.instructions[address].data

        local target_symbols = symbols:get_relative_memory_area(bank_num, data)
        if target_symbols then
            local label = target_symbols.labels[data]
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
    return function(bank, address, symbols)
        local bank_num = bank.bank_num

        local bank_symbols = symbols:get_init_rom_bank(bank_num)
        local op_symbol = bank_symbols.operands[address]

        if op_symbol then
            -- Format signed instruction with op symbol
            return string.format(string_format, op_symbol)
        end

        local data = bank.instructions[address].data

        if is_relative then
            local label = bank_symbols.labels[address + data + 2]

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

local instruction_formatters = {
    -- "ld" Instructions --

    ["ld a, n8"] = get_byte_op_instruction_formatter("ld a, $%02x", "ld a, %s"),
    ["ld b, n8"] = get_byte_op_instruction_formatter("ld b, $%02x", "ld a, %s"),
    ["ld c, n8"] = get_byte_op_instruction_formatter("ld c, $%02x", "ld a, %s"),
    ["ld d, n8"] = get_byte_op_instruction_formatter("ld d, $%02x", "ld a, %s"),
    ["ld e, n8"] = get_byte_op_instruction_formatter("ld e, $%02x", "ld e, %s"),
    ["ld h, n8"] = get_byte_op_instruction_formatter("ld h, $%02x", "ld h, %s"),
    ["ld l, n8"] = get_byte_op_instruction_formatter("ld l, $%02x", "ld l, %s"),

    ["ld a, [n16]"] = get_octet_op_instruction_formatter("ld a, [$%04x]", "ld a, %s"),
    ["ld [n16], a"] = get_octet_op_instruction_formatter("ld [$%04x], a", "ld %s, a", "ld [%s], a"),

    ["ldio a, [$ff00+n8]"] = get_hram_op_instruction_formatter("ldio a, [$ff00+$%02x]", "ldio a, %s"),
    ["ldio [$ff00+n8], a"] = get_hram_op_instruction_formatter("ldio [$ff00+$%02x], a", "ldio %s, a"),

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
    ["ld [n16], sp"] = get_octet_op_instruction_formatter("ld [$%04x], sp", "ld %s, sp", "ld [%s], sp"),

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

local Formatter = {}

Formatter.new = function(self, options)
    local formatter = {
        options = options,
    }

    setmetatable(formatter, self)
    self.__index = self

    return formatter
end

Formatter.add_address = function(self, line, bank_num, address)
    if self.options.no_address then
        return line
    end

    local len = #line
    while len < 60 do
        line = line .. " "
        len = len + 1
    end

    return line .. string.format("; %02x:%04x", bank_num, address)
end

Formatter.format_bank_header = function(self, bank_num)
    if bank_num == 0 then
        return 'SECTION "ROM Bank $000", ROM0[$0000]'
    end

    return string.format('SECTION "ROM Bank $%03x", ROMX[$4000], BANK[$%03x]', bank_num, bank_num)
end

Formatter.format_comment = function(self, comment)
    if comment == "" then
        return ";"
    end
    return string.format("; %s", comment)
end

Formatter.format_instruction = function(self, bank, address, symbols)
    local instruction = bank.instructions[address]

    local instruction_type = instruction.instruc

    if not instruction_type then
        error(string.format("Unrecognized instruction: %s", instruction.instruc))
    end

    local output
    local instruction_formatter = instruction_formatters[instruction_type]

    if instruction_formatter then
        -- Format complex instruction
        output = instruction_formatter(bank, address, symbols)
    else
        -- Format basic instruction
        output = instruction_type
    end

    -- TODO: configurable indentation
    return self:add_address("    " .. output, bank.bank_num, address)
end

Formatter.get_text_output = function(self, bank, address, size)
    local data = bank.data

    local index = (address % 0x4000) + 1
    local end_index = index + size
    -- TODO: configurable indentation
    local output = "    db "

    local has_preceeding_byte = false
    local has_preceeding_char = false

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

            if not has_preceeding_char then
                output = output .. '"'
            elseif has_preceeding_byte then
                output = output .. ", "
            end

            if char == '"' or char == "\\" then
                -- Char which needs to be escaped
                output = output .. "\\" .. char
            elseif byte == "\t" then
                -- Tab
                output = output .. "\\t"
            elseif byte == "\n" then
                -- Newline
                output = output .. "\\n"
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

    return self:add_address(output, bank.bank_num, address)
end

Formatter.format_data = function(self, bank, address, symbols)
    local bank_num = bank.bank_num
    local bank_size = bank.size
    local data = bank.data

    local bank_symbols = symbols:get_init_rom_bank(bank_num)
    local region = bank_symbols.regions[address] or {}

    local size = 0
    local index = (address % 0x4000) + 1

    -- Get data size

    if region.region_type == "data" or region.region_type == "text" and region.size > 0 then
        -- Get data size for region: can only be terminated by end of bank or file

        local files = bank_symbols.files

        local check_address = address
        local check_index = index

        repeat
            size = size + 1
            check_address = check_address + 1
            check_index = check_index + 1
        until check_index > bank_size or size >= region.size or files[check_address]
    else
        -- Get data size for plain data: can be terminated by instructions, new labels, comments, or regions

        local instructions = bank.instructions
        local labels = bank_symbols.labels
        local comments = bank_symbols.comments
        local regions = bank_symbols.regions
        local files = bank_symbols.files

        local check_address = address
        local check_index = index

        repeat
            size = size + 1
            check_address = check_address + 1
            check_index = check_index + 1
        until check_index > bank_size
            or instructions[check_address]
            or labels[check_address]
            or comments[check_address]
            or regions[check_address]
            or files[check_address]
    end

    -- Output text

    if region.region_type == "text" then
        return size, self:get_text_output(bank, address, size)
    end

    -- Build data output

    local output = ""
    local remaining_bytes = size

    -- Output by increments of 8
    if size >= 8 then
        repeat
            if output ~= "" then
                output = output .. "\n"
            end

            output = output
                .. self:add_address(
                    string.format(
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
                    ),
                    bank_num,
                    address
                )

            remaining_bytes = remaining_bytes - 8
            address = address + 8
            index = index + 8
        until remaining_bytes < 8
    end

    -- Output remaining bytes
    if remaining_bytes > 0 then
        -- TODO: configurable indentation
        local last_line = string.format("    db $%02x", string.byte(data:sub(index, index)))

        remaining_bytes = remaining_bytes - 1
        index = index + 1

        while remaining_bytes > 0 do
            last_line = last_line .. string.format(", $%02x", string.byte(data:sub(index, index)))

            remaining_bytes = remaining_bytes - 1
            index = index + 1
        end

        if output ~= "" then
            output = output .. "\n"
        end

        output = output .. self:add_address(last_line, bank_num, address)
    end

    return size, output
end

Formatter.format_file_symbol = function(self, bank, address, symbols)
    local bank_num = bank.bank_num
    local file_symbol = symbols.rom_banks[bank_num].files[address]
    -- TODO: configurable indentation
    return self:add_address(string.format('    INCBIN("%s")', file_symbol.file_name), bank_num, address)
end

Formatter.write_file_symbol = function(self, bank, address, base_path, symbols)
    local bank_num = bank.bank_num
    local index = (address % 0x4000) + 1
    local file_symbol = symbols.rom_banks[bank_num].files[address]

    local file_name = file_symbol.file_name
    local file_path = string.format("%s/%s", base_path, file_name)
    local file = io.open(file_path, "wb")

    file:write(bank.data:sub(index, index + file_symbol.size - 1))
    file:close()
end

Formatter.format_rom_jump_call_location_labels = function(self, rom)
    local labels = {}

    for bank_num = 0, rom.nbanks - 1 do
        labels[bank_num] = {}
    end

    if self.options.no_auto_labels then
        return labels
    end

    local jump_locations = rom.jump_locations
    local relative_jump_locations = rom.relative_jump_locations
    local call_locations = rom.call_locations
    local rst_call_locations = rom.rst_call_locations

    for bank_num = 0, rom.nbanks - 1 do
        local bank_jump_locations = jump_locations[bank_num]
        local bank_relative_jump_locations = relative_jump_locations[bank_num]
        local bank_call_locations = call_locations[bank_num]

        for address in pairs(bank_relative_jump_locations) do
            labels[bank_num][address] = { string.format("jr_%02x_%04x", bank_num, address) }
        end

        for address in pairs(bank_jump_locations) do
            if bank_relative_jump_locations[address] then
                labels[bank_num][address] = { string.format("jump_%02x_%04x", bank_num, address) }
            else
                labels[bank_num][address] = { string.format("jp_%02x_%04x", bank_num, address) }
            end
        end

        for address in pairs(bank_call_locations) do
            labels[bank_num][address] = { string.format("call_%02x_%04x", bank_num, address) }
        end
    end

    for address in pairs(rst_call_locations) do
        labels[0x00][address] = { string.format("rst_%02x", address) }
    end

    return labels
end

Formatter.format_sram_header = function(self, bank_num, address)
    return string.format('SECTION "SRAM_%02x_%04x", SRAM[$%04x], BANK[%d]\n', bank_num, address, address, bank_num)
end

Formatter.format_wram_header = function(self, bank_num, address)
    if bank_num == 0 then
        return string.format('SECTION "WRAM_%02x_%04x", WRAM0[$%04x]\n', bank_num, address, address)
    end
    return string.format('SECTION "WRAM_%02x_%04x", WRAMX[$%04x], BANK[$%02x]\n', bank_num, address, address, bank_num)
end

Formatter.format_hram_header = function(self, address)
    return string.format('SECTION "HRAM_%04x", HRAM[$%04x]\n', address, address)
end

Formatter.generate_memory_symbols = function(self, file, labels, comments, address)
    if comments[address] then
        for _, comment in pairs(comments[address]) do
            file:write(self:format_comment(comment))
            file:write("\n")
        end
    end

    for _, label in pairs(labels[address]) do
        file:write(label)
        file:write(":\n")
    end

    -- TODO: configurable indentation
    file:write("    ds 1\n")
end

Formatter.generate_memory_file = function(self, base_path, symbols)
    local memory_file_name = "memory.asm"
    local memory_path = string.format("%s/%s", base_path, memory_file_name)
    local memory_file = io.open(memory_path, "wb")

    local has_labels = false

    -- Write SRAM memory
    local max_sram_bank = table.maxn(symbols.sram_banks)
    if max_sram_bank ~= nil then
        for sram_bank_num = 0, max_sram_bank do
            local sram_symbols = symbols:get_init_sram_bank(sram_bank_num)

            local labels = sram_symbols.labels
            local comments = sram_symbols.comments
            local last_address = -2

            for address = 0xa000, 0xbfff do
                if labels[address] then
                    if last_address ~= address - 1 then
                        if has_labels then
                            memory_file:write("\n")
                        end
                        memory_file:write(self:format_sram_header(sram_bank_num, address))
                    end

                    self:generate_memory_symbols(memory_file, labels, comments, address)

                    has_labels = true
                    last_address = address
                end
            end
        end

    end

    -- Write WRAM memory
    local max_wram_bank = table.maxn(symbols.wram_banks)
    if max_wram_bank ~= nil then
        for wram_bank_num = 0, max_wram_bank do
            local wram_symbols = symbols.wram_banks[wram_bank_num] or {}

            local labels = wram_symbols.labels or {}
            local comments = wram_symbols.comments or {}
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
                if labels[address] then
                    if last_address ~= address - 1 then
                        if has_labels then
                            memory_file:write("\n")
                        end
                        memory_file:write(self:format_wram_header(wram_bank_num, address))
                    end

                    self:generate_memory_symbols(memory_file, labels, comments, address)

                    has_labels = true
                    last_address = address
                end
            end
        end
    end

    -- Write HRAM memory
    local labels = symbols.hram.labels
    local comments = symbols.hram.comments
    local last_address = -2
    for address = 0xff80, 0xfffe do
        if labels[address] then
            if last_address ~= address - 1 then
                if has_labels then
                    memory_file:write("\n")
                end
                memory_file:write(self:format_hram_header(address))
            end

            self:generate_memory_symbols(memory_file, labels, comments, address)

            has_labels = true
            last_address = address
        end
    end

    memory_file:close()

    return memory_file_name
end

Formatter.generate_include_files = function(self, base_path, main_file)
    for _, include_source_path in pairs(self.options.include) do
        local include_file_name = include_source_path:gsub(".*/", "")
        local include_path = string.format("%s/%s", base_path, include_file_name)

        local include_source_file = io.open(include_source_path, "rb")
        local include_file = io.open(include_path, "wb")

        include_file:write(include_source_file:read("a"))

        include_source_file:close()
        include_file:close()

        -- Add include file to main ASM
        main_file:write(string.format('INCLUDE "%s"\n', include_file_name))
    end
end

Formatter.generate_bank_file = function(self, base_path, rom, symbols, main_file, bank_num, jump_call_labels)
    local bank = rom.banks[bank_num]

    -- Get bank ASM file
    local file_name = string.format("bank_%03x.asm", bank_num)
    local path = string.format("%s/%s", base_path, file_name)
    local file = io.open(path, "wb")

    -- Write bank ASM to main ASM file
    main_file:write(string.format('INCLUDE "%s"\n', file_name))

    -- Write bank header
    file:write(self:format_bank_header(bank_num))
    file:write("\n\n")

    local instructions = bank.instructions

    local bank_symbols = symbols:get_init_rom_bank(bank_num)
    local labels = bank_symbols.labels
    local comments = bank_symbols.comments
    local replacements = bank_symbols.replacements
    local files = bank_symbols.files
    local bank_jump_call_labels = jump_call_labels[bank_num]

    local address
    local next_bank_start

    if bank_num == 0 then
        address = 0
        next_bank_start = 0x4000
    else
        address = 0x4000
        next_bank_start = 0x8000
    end

    while address < next_bank_start do
        -- Write labels
        local address_labels = labels[address] or bank_jump_call_labels[address]
        if address_labels then
            if address % 0x4000 ~= 0x0000 then
                file:write("\n")
            end

            for _, label in pairs(address_labels) do
                file:write(label)
                file:write(":\n")
            end
        end

        -- Write comments
        if comments[address] then
            for _, comment in pairs(comments[address]) do
                file:write(self:format_comment(comment))
                file:write("\n")
            end
        end

        -- Get replacement
        local replacement = replacements[address]
        local file_symbol = files[address]

        if replacement then
            -- Replacement found
            -- TODO: configurable indentation
            file:write("    ")
            file:write(replacement.body)
            address = address + replacement.size
        elseif file_symbol then
            -- File found
            self:write_file_symbol(bank, address, base_path, symbols)
            file:write(self:format_file_symbol(bank, address, symbols))
            address = address + file_symbol.size
        else
            -- No replacement

            -- Get instruction, if any
            local instruction = instructions[address]

            if instruction then
                -- Write instruction
                file:write(self:format_instruction(bank, address, symbols))
                address = address + (instruction.size or 1)
            else
                -- Write data
                local data_size, formatted_data = self:format_data(bank, address, symbols)
                file:write(formatted_data)
                address = address + data_size
            end
        end

        -- Write newline
        file:write("\n")
    end

    file:close()
end

Formatter.generate_files = function(self, base_path, rom, symbols)
    -- TODO: create base if it does not exist

    -- TODO: better error handling
    if not base_path then
        error("No base path")
    end

    -- Generate memory file

    local memory_file_name = self:generate_memory_file(base_path, symbols)

    -- Open main ASM file

    local main_path = string.format("%s/%s", base_path, self.options.main)

    local main_file = io.open(main_path, "wb")

    -- Add memory file to main ASM
    main_file:write(string.format('INCLUDE "%s"\n', memory_file_name))

    -- Generate includes files

    self:generate_include_files(base_path, main_file)

    -- Generate bank ASM files

    local jump_call_labels = self:format_rom_jump_call_location_labels(rom)

    for bank_num = 0, rom.nbanks - 1 do
        self:generate_bank_file(base_path, rom, symbols, main_file, bank_num, jump_call_labels)
    end

    main_file:close()
end

return {
    Formatter = Formatter,
}
