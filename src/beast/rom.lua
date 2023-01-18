local get_region_symbols = require("beast/symbol").get_region_symbols

local parse_next_instruction = require("beast/instruction").parse_next_instruction

local init_rom_bank_metadata
local add_jump_call_location
local add_context

local function get_rst_instruction_handler(target_address)
    return function(rom, bank_num, address)
        rom.rst_call_locations[target_address] = true
        add_jump_call_location(rom, 0x00, target_address, bank_num, address)
    end
end

local function call_instruction_handler(rom, bank_num, address, instruction)
    local target_address = instruction.data

    -- TODO: detect ROM location automatically based on context
    if target_address >= 0x4000 and bank_num == 0 then
        return
    end

    local target_bank_num = target_address < 0x4000 and 0 or bank_num

    local call_locations = rom.call_locations[target_bank_num]
    if call_locations then
        call_locations[target_address] = true
    end

    add_jump_call_location(rom, target_bank_num, target_address, bank_num, address)
end

local function jump_instruction_handler(rom, bank_num, address, instruction)
    local target_address = instruction.data

    -- TODO: detect ROM location automatically based on context
    if target_address >= 0x4000 and bank_num == 0 then
        return
    end

    local target_bank_num = target_address < 0x4000 and 0 or bank_num

    local jump_locations = rom.jump_locations[target_bank_num]
    if jump_locations then
        jump_locations[target_address] = true
    end

    add_jump_call_location(rom, target_bank_num, target_address, bank_num, address)
end

local function relative_jump_instruction_handler(rom, bank_num, address, instruction)
    local target_address = address + instruction.data

    if bank_num == 0 then
        if target_address < 0 or target_address >= 0x4000 then
            return
        end
    else
        if target_address < 0x4000 or target_address >= 0x8000 then
            return
        end
    end

    local jump_locations = rom.relative_jump_locations[bank_num]
    if jump_locations then
        jump_locations[target_address] = true
    end

    add_jump_call_location(rom, bank_num, target_address, bank_num, address)
end

local instruction_handlers = {
    ["rst $00"] = get_rst_instruction_handler(0x0000),
    ["rst $08"] = get_rst_instruction_handler(0x0008),
    ["rst $10"] = get_rst_instruction_handler(0x0010),
    ["rst $18"] = get_rst_instruction_handler(0x0018),
    ["rst $20"] = get_rst_instruction_handler(0x0020),
    ["rst $28"] = get_rst_instruction_handler(0x0028),
    ["rst $30"] = get_rst_instruction_handler(0x0030),
    ["rst $38"] = get_rst_instruction_handler(0x0038),
    ["call n16"] = call_instruction_handler,
    ["call c, n16"] = call_instruction_handler,
    ["call z, n16"] = call_instruction_handler,
    ["call nc, n16"] = call_instruction_handler,
    ["call nz, n16"] = call_instruction_handler,
    ["jp n16"] = jump_instruction_handler,
    ["jp c, n16"] = jump_instruction_handler,
    ["jp z, n16"] = jump_instruction_handler,
    ["jp nc, n16"] = jump_instruction_handler,
    ["jp nz, n16"] = jump_instruction_handler,
    ["jr e8"] = relative_jump_instruction_handler,
    ["jr c, e8"] = relative_jump_instruction_handler,
    ["jr z, e8"] = relative_jump_instruction_handler,
    ["jr nc, e8"] = relative_jump_instruction_handler,
    ["jr nz, e8"] = relative_jump_instruction_handler,
}

local function create_context()
    return {}
end

local function create_bank(bank_num, options)
    return {
        bank_num = bank_num,
        size = 0,
        data = "",
        instructions = {},
        options = options or {},
    }
end

local function read_bank(bank, file)
    bank.data = file:read(0x4000)
    bank.size = bank.data and #bank.data or 0
end

local function create_rom(options)
    local rom = {
        nbanks = 0,
        banks = {},
        options = options or {},
        jump_call_locations = {},
        unparsed_jump_call_locations = {},
        jump_locations = {},
        relative_jump_locations = {},
        call_locations = {},
        rst_call_locations = {},
        context = {},
        unparsed_context = {},
    }

    init_rom_bank_metadata(rom, 0x00)

    -- Add default code locations

    -- TODO: interrupts?
    -- 00:0150 - Entrypoint
    add_jump_call_location(rom, 0x00, 0x0150)

    return rom
end

function init_rom_bank_metadata(rom, bank_num)
    rom.jump_call_locations[bank_num] = {}
    rom.unparsed_jump_call_locations[bank_num] = {}
    rom.jump_locations[bank_num] = {}
    rom.relative_jump_locations[bank_num] = {}
    rom.call_locations[bank_num] = {}
    rom.context[bank_num] = {}
    rom.unparsed_context[bank_num] = {}
end

function add_jump_call_location(rom, target_bank_num, target_address, source_bank_num, source_address)
    local bank_jump_call_locations = rom.jump_call_locations[target_bank_num]
    if bank_jump_call_locations[target_address] then
        return
    end

    local source = { source_bank_num, source_address }
    bank_jump_call_locations[target_address] = source
    rom.unparsed_jump_call_locations[target_bank_num][target_address] = source
end

function add_context(rom, bank_num, address)
    local bank_context = rom.context[bank_num]
    if bank_context[address] then
        return nil
    end

    local context = create_context()
    bank_context[address] = context
    rom.unparsed_context[bank_num][address] = context
    return context
end

local function read_rom_bank(rom, file)
    local bank_num = rom.nbanks

    -- Read bank
    local bank = create_bank(bank_num, rom.options)
    read_bank(bank, file)
    if bank.size == 0 then
        return
    end

    -- Add bank
    rom.banks[bank_num] = bank
    rom.nbanks = bank_num + 1

    -- Initialize metadata (bank 0 already initialized)
    if bank_num ~= 0x00 then
        init_rom_bank_metadata(rom, bank_num)
    end

    return bank
end

local function read_rom_banks(rom, file)
    while read_rom_bank(rom, file) do
        --
    end
end

-- TODO: when adding automatic code comments, treat region start/end as new context
-- TODO: when automatically determining bank 0 ROM jump location, treat region start/end as new context
local function parse_code_regions(rom, symbols, bank_num)
    local bank = rom.banks[bank_num]

    local instructions = bank.instructions
    local data = bank.data

    local regions = (symbols.rom_banks[bank_num] or {}).regions

    for region in get_region_symbols(symbols, bank_num) do
        if region.region_type == "code" then
            local address = region.address
            local remaining = region.size

            -- Don't parse regions that have already been parsed
            if add_context(rom, bank_num, address) then
                while remaining > 0 do
                    local index = address % 0x4000

                    local other_region = regions[address]

                    if other_region and (other_region.region_type == "data" or other_region.region_type == "text") then
                        -- Handle data region
                        local size = other_region.size or 1
                        remaining = remaining - size
                        address = address + size
                    else
                        -- Parse instruction
                        local instruction = parse_next_instruction(data, index, remaining)

                        if instruction then
                            -- Handle instruction

                            instructions[address] = instruction

                            -- Iterate loop variables
                            local size = instruction.size or 1
                            remaining = remaining - size
                            address = address + size

                            -- Run instruction handler if available
                            local instruction_handler = instruction_handlers[instruction.instruc]
                            if instruction_handler then
                                instruction_handler(rom, bank_num, address, instruction)
                            end
                        else
                            -- Handle data

                            -- Iterate loop variables
                            -- Data inside of code regions is treated as 1 byte large
                            remaining = remaining - 1
                            address = address + 1
                        end
                    end
                end
            end
        end
    end
end

-- TODO: count unconditional jumps as code end and treat return as new jump location
local function parse_jump_call_location(rom, symbols, bank_num, address)
    local regions = (symbols.rom_banks[bank_num] or {}).regions or {}
    local bank = rom.banks[bank_num]

    local instructions = bank.instructions
    local data = bank.data

    add_context(rom, bank_num, address)

    while true do
        local index = address % 0x4000

        -- Check for data region - terminates call/jump location
        -- TODO: optional warn
        local region = regions[address]
        if region then
            local region_type = region.region_type
            if region_type == "data" or region_type == "text" then
                break
            end
        end

        -- Parse address
        local instruction = parse_next_instruction(data, index)
        if not instruction then
            return
        end

        -- Record instruction
        instructions[address] = instruction

        -- Run instruction handler if available
        local instruction_handler = instruction_handlers[instruction.instruc]
        if instruction_handler then
            instruction_handler(rom, bank_num, address, instruction)
        end

        -- End parsing if instruction ends code
        if instruction.code_end then
            return
        end

        -- Iterate address
        address = address + (instruction.size or 1)
    end
end

local function parse_jump_call_locations(rom, symbols)
    local unparsed_jump_call_locations = rom.unparsed_jump_call_locations

    -- Parse call/jump locations
    local has_parsed = false
    local has_new_code_locations = true
    while has_new_code_locations do
        has_new_code_locations = false

        for bank_num, bank_jump_call_locations in pairs(unparsed_jump_call_locations) do
            -- Clear call/jump locations for next loop
            unparsed_jump_call_locations[bank_num] = {}

            for address in pairs(bank_jump_call_locations) do
                parse_jump_call_location(rom, symbols, bank_num, address)
                has_parsed = true
                has_new_code_locations = true
            end
        end
    end

    return has_parsed
end

local function read_rom(rom, symbols, file)
    read_rom_banks(rom, file)

    for bank_num = 0, rom.nbanks - 1 do
        parse_code_regions(rom, symbols, bank_num)
    end

    if not rom.options.no_code_detection then
        parse_jump_call_locations(rom, symbols)
    end
end

return {
    create_bank = create_bank,
    create_rom = create_rom,
    read_rom = read_rom,
}
