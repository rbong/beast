-- TODO: add line numbers

local function get_byte_op_instruction_formatter(byte_format, string_format)
    return function(bank, instruction, op_symbol)
        if op_symbol then
            return string.format(string_format, op_symbol)
        end
        return string.format(byte_format, instruction.data)
    end
end

local function get_hram_op_instruction_formatter(byte_format, string_format)
    return function(bank, instruction, op_symbol)
        if op_symbol then
            return string.format(string_format, op_symbol)
        end
        return string.format(byte_format, instruction.data)
    end
end

local function get_octet_op_instruction_formatter(octet_format, string_format)
    return function(bank, instruction, op_symbol)
        if op_symbol then
            return string.format(string_format, op_symbol)
        end
        return string.format(octet_format, instruction.data)
    end
end

local function get_signed_op_instruction_formatter(signed_format, string_format, is_relative)
    return function(bank, instruction, op_symbol)
        if op_symbol then
            return string.format(string_format, op_symbol)
        elseif is_relative then
            return string.format(signed_format, instruction.data + 2)
        else
            return string.format(signed_format, instruction.data)
        end
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
    ["ld [n16], a"] = get_octet_op_instruction_formatter("ld [$%04x], a", "ld %s, a"),

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
    ["ld [n16], sp"] = get_octet_op_instruction_formatter("ld [$%04x], sp", "ld %s, sp"),

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

Formatter.format_bank_header = function(self, bank_num)
    if bank_num == 0 then
        return 'SECTION "ROM Bank $000", ROM0[$0000]'
    end

    return string.format('SECTION "ROM Bank $%03x", ROMX[$4000], BANK[$%03x]', bank_num, bank_num)
end

-- TODO: use labels in formatted instructions
Formatter.format_instruction = function(self, bank, address, bank_symbols)
    local instruction = bank.instructions[address]

    local instruction_type = instruction.instruc

    if not instruction_type then
        error(string.format("Unrecognized instruction: %s", instruction.instruc))
    end

    local instruction_formatter = instruction_formatters[instruction_type]

    -- Format complex instruction
    if instruction_formatter then
        local op_symbol = (bank_symbols.operands or {})[address]
        return instruction_formatter(bank, instruction, op_symbol)
    end

    -- Format basic instruction
    return instruction_type
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

    return output
end

-- TODO: format text regions
Formatter.format_data = function(self, bank, address, bank_symbols)
    local bank_size = bank.size
    local data = bank.data
    local region = (bank_symbols.regions or {})[address] or {}

    local size = 0
    local index = (address % 0x4000) + 1

    -- Get data size

    if region.region_type == "data" or region.region_type == "text" and region.size > 0 then
        -- Get data size for region: can only be terminated by end of bank

        size = region.size
        if index + size - 1 > bank_size then
            size = bank_size - index + 1
        end
    else
        -- Get data size for plain data: can be terminated by instructions, new labels, comments, or regions

        local instructions = bank.instructions
        local labels = bank_symbols.labels or {}
        local comments = bank_symbols.comments or {}
        local regions = bank_symbols.regions or {}

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
    end

    -- Build data output

    if region.region_type == "text" then
        return size, self:get_text_output(bank, address, size)
    end

    local output = ""
    local remaining_bytes = size

    -- Output by increments of 8
    if size >= 8 then
        repeat
            if output ~= "" then
                output = output .. "\n"
            end

            output = output
                .. string.format(
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

            remaining_bytes = remaining_bytes - 8
            address = address + 8
            index = index + 8
        until remaining_bytes < 8
    end

    -- Output remaining bytes
    local line_bytes = 0
    while remaining_bytes > 0 do
        local byte = string.byte(data:sub(index, index))

        if line_bytes == 0 then
            if output ~= "" then
                output = output .. "\n"
            end
            -- TODO: configurable indentation
            output = output .. string.format("    db $%02x", byte)
        else
            output = output .. string.format(", $%02x", byte)
        end

        remaining_bytes = remaining_bytes - 1
        address = address + 1
        index = index + 1
        line_bytes = (line_bytes + 1) % 8
    end

    return size, output
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

-- TODO: replace operands
Formatter.generate_asm = function(self, base_path, rom, symbols)
    -- TODO: create base if it does not exist

    -- TODO: better error handling
    if not base_path then
        error("No base path")
    end

    local bank_symbols = symbols.rom_banks or {}

    local jump_call_labels = self:format_rom_jump_call_location_labels(rom)

    for bank_num, bank in pairs(rom.banks) do
        -- Get bank ASM file
        local path = string.format("%s/bank_%03x.asm", base_path, bank_num)
        local file = io.open(path, "wb")

        -- Write bank header
        file:write(self:format_bank_header(bank_num))
        file:write("\n\n")

        local instructions = bank.instructions

        local curr_bank_symbols = bank_symbols[bank_num] or {}
        local labels = curr_bank_symbols.labels or {}
        local comments = curr_bank_symbols.comments or {}
        local replacements = curr_bank_symbols.replacements or {}
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
                    if comment == "" then
                        file:write(";")
                    else
                        file:write("; ")
                        file:write(comment)
                    end
                    file:write("\n")
                end
            end

            -- Get replacement
            local replacement = replacements[address]

            if replacement then
                -- Replacement found
                -- TODO: configurable indentation
                file:write("    ")
                file:write(replacement.body)
                address = address + replacement.size
            else
                -- No replacement

                -- Get instruction, if any
                local instruction = instructions[address]

                if instruction then
                    -- Write instruction
                    -- TODO: configurable indentation
                    file:write("    ")
                    file:write(self:format_instruction(bank, address, curr_bank_symbols))
                    address = address + (instruction.size or 1)
                else
                    -- Write data
                    local data_size, formatted_data = self:format_data(bank, address, curr_bank_symbols)
                    file:write(formatted_data)
                    address = address + data_size
                end
            end

            -- Write newline
            file:write("\n")
        end

        file:close()
    end
end

return {
    Formatter = Formatter,
}
