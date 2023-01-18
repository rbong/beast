local function create_rom_symbols(bank_num)
    return {
        labels = {},
        comments = {},
        -- TODO: warn when overlapping regions are specified
        regions = {},
        _regions_list = {},
        -- TODO: warn when overlapping replacements are specified
        replacements = {},
        operands = {},
        bank_num = bank_num,
        is_ram = false,
        is_rom = true,
    }
end

local function create_ram_symbols(bank_num)
    return {
        labels = {},
        comments = {},
        bank_num = bank_num,
        is_rom = false,
        is_ram = true,
    }
end

local function create_symbols(options)
    return {
        rom_banks = {},
        sram = create_ram_symbols(),
        wram_banks = {},
        hram = create_ram_symbols(),
        options = options or {},
    }
end

local function _get_init_rom_bank(sym, bank_num)
    if not sym.rom_banks[bank_num] then
        sym.rom_banks[bank_num] = create_rom_symbols(bank_num)
    end
    return sym.rom_banks[bank_num]
end

local function _get_init_wram_bank(sym, bank_num, address)
    if address >= 0xd000 and bank_num == 0 then
        bank_num = 1
    end
    if not sym.wram_banks[bank_num] then
        sym.wram_banks[bank_num] = create_ram_symbols(bank_num)
    end
    return sym.wram_banks[bank_num]
end

local function get_memory_area(sym, bank_num, address)
    -- Check bank
    if bank_num < 0 then
        error(string.format("Invalid bank target: %x:%x", bank_num, address))
    end

    -- Check address
    if address < 0 or address > 0xffff then
        error(string.format("Invalid address target: %x:%x", bank_num, address))
    end
    if address >= 0xfea0 and address < 0xff00 then
        error(string.format("Invalid address target: %x:%x", bank_num, address))
    end

    -- Check ROM bank
    if address < 0x4000 and bank_num ~= 0 then
        error(string.format("Invalid ROM target: %x:%x", bank_num, address))
    end
    if address >= 0x4000 and address < 0x8000 and bank_num == 0 then
        error(string.format("Invalid ROM target: %x:%x", bank_num, address))
    end

    -- Check for VRAM target
    if address >= 0x8000 and address < 0xa000 then
        error(string.format("Unsupported target in VRAM: %x:%x", bank_num, address))
    end

    -- Check WRAM bank
    if address >= 0xc000 and address < 0xd000 and bank_num ~= 0 then
        error(string.format("Invalid WRAM target: %x:%x", bank_num, address))
    end

    -- Check for ECHO RAM target
    if address >= 0xe000 and address < 0xfe00 then
        error(string.format("Unsupported target in ECHO RAM: %x:%x", bank_num, address))
    end

    -- Check for OAM target
    if address >= 0xfe00 and address < 0xfea0 then
        error(string.format("Unsupported target in OAM: %x:%x", bank_num, address))
    end

    -- Check for IO register target
    if address >= 0xff00 and address < 0xff80 then
        error(string.format("Unsupported target in IO registers: %x:%x", bank_num, address))
    end

    -- Check HRAM bank
    if address >= 0xff80 and address < 0xfff and bank_num ~= 0 then
        error(string.format("Invalid HRAM target: %x:%x", bank_num, address))
    end

    -- Check for IE target
    if address == 0xffff then
        error(string.format("Unsupported target IE: %x:%x", bank_num, address))
    end

    if address < 0x8000 then
        return _get_init_rom_bank(sym, bank_num, address)
    elseif address < 0xc000 then
        return sym.sram
    elseif address < 0xe000 then
        return _get_init_wram_bank(sym, bank_num, address)
    elseif address < 0xffff then
        return sym.hram
    end
end

local function add_replacement_symbol(sym, bank_num, address, size, body)
    local mem = get_memory_area(sym, bank_num, address)
    if mem.is_ram then
        error(string.format("Attempted to add replacement at RAM target: %x:%x", bank_num, address))
    end

    mem.replacements[address] = { size = size, body = body }
end

local function set_op_symbol(sym, bank_num, address, value)
    local mem = get_memory_area(sym, bank_num, address)
    if mem.is_ram then
        error(string.format("Attempted to add operand at RAM target: %x:%x", bank_num, address))
    end

    mem.operands[address] = value
end

local function add_comment_symbol(sym, bank_num, address, body)
    local comments = get_memory_area(sym, bank_num, address).comments

    if comments[address] then
        table.insert(comments[address], body)
    else
        comments[address] = { body }
    end
end

local function add_label_symbol(sym, bank_num, address, body)
    local labels = get_memory_area(sym, bank_num, address).labels

    if labels[address] then
        table.insert(labels[address], body)
    else
        labels[address] = { body }
    end
end

local function add_region_symbol(sym, bank_num, address, region_type, size)
    local mem = get_memory_area(sym, bank_num, address)
    if mem.is_ram then
        error(string.format("Attempted to add region to RAM target: %x:%x", bank_num, address))
    end

    local region = { region_type = region_type, address = address, size = size }
    mem.regions[address] = region
    -- Add the region to a list so it can be iterated through
    table.insert(mem._regions_list, region)
end

local function get_region_symbols(sym, bank_num)
    local i = 1
    local regions
    local regions_list

    if sym.rom_banks[bank_num] then
        regions = sym.rom_banks[bank_num].regions
        regions_list = sym.rom_banks[bank_num]._regions_list
    end

    return function()
        if not regions then
            return
        end

        local region
        -- Skip over regions that were overwritten
        repeat
            region = regions_list[i]
            i = i + 1
        until not region or regions[region.address]

        if not region then
            return
        end

        return region
    end
end

local function parse_comment(sym, bank_num, address, body)
    -- Trim first whitespace on body
    body = body:gsub("^%s", "")
    add_comment_symbol(sym, bank_num, address, body)
end

local function parse_replacement(sym, bank_num, address, replace_opts, body)
    local _, _, size = replace_opts:find("^:(%x+)$")

    if size == nil then
        -- Unreadable size opt
        return
    end

    -- Parse size
    size = tonumber(size, 16)

    -- Trim leading whitespace on body
    body = body:gsub("^%s*", "")

    add_replacement_symbol(sym, bank_num, address, size, body)
end

local function parse_op(sym, bank_num, address, op_opts, body)
    if op_opts ~= "" then
        -- Unrecognized data after :op
        return
    end

    -- Trim leading whitespace on body
    body = body:gsub("^%s*", "")

    set_op_symbol(sym, bank_num, address, body)
end

local function parse_region(sym, bank_num, address, label, region_opts)
    -- Trim leading "." from label to get region type
    local region_type = label:gsub("^%.", "")

    local _, _, size = region_opts:find("^:(%x+)$")

    if size == nil then
        -- Unreadable size opt
        return
    end

    size = tonumber(size, 16)

    add_region_symbol(sym, bank_num, address, region_type, size)
end

local function parse_commented_line(sym, bank_num, address, opts, body)
    if opts == "" then
        parse_comment(sym, bank_num, address, body)
        return
    end

    -- Break the opts into groups
    local _, _, symbol_type, symbol_type_opts = opts:find("^:([^:]*)(.*)")

    if symbol_type == "replace" then
        parse_replacement(sym, bank_num, address, symbol_type_opts, body)
    elseif symbol_type == "op" then
        parse_op(sym, bank_num, address, symbol_type_opts, body)
    end
end

local function parse_uncommented_line(sym, bank_num, address, opts, body)
    local _, _, label, label_opts = body:find("^%s*([^%s:]+)(.*)")

    if label == nil then
        return
    end

    if label == ".code" or label == ".data" or label == ".text" then
        parse_region(sym, bank_num, address, label, label_opts)
    elseif label_opts ~= "" then
        -- Extra label opts, unknown label type
        return
    else
        -- Add plain label
        add_label_symbol(sym, bank_num, address, label)
    end
end

local function parse_line(sym, line)
    -- Break the line into groups
    local start_index, _, leading_semicolons, bank_num, address, opts, body =
        line:find("^%s*(;*)%s*(%x%x):(%x%x%x%x)([^%s]*)(.*)")

    -- Unparsable symbols
    if not start_index then
        return
    end

    -- Parse bank/address
    bank_num = tonumber(bank_num, 16)
    address = tonumber(address, 16)

    -- Trim first whitespace on body (used to separate from opts)
    body = body:sub(2)

    if leading_semicolons == ";;" then
        -- The line starts with ";;"
        parse_commented_line(sym, bank_num, address, opts, body)
    elseif leading_semicolons == "" then
        -- The line does not start with any semicolons
        parse_uncommented_line(sym, bank_num, address, opts, body)
    end
end

local function read_symbols(sym, file)
    for line in file:lines() do
        parse_line(sym, line)
    end
end

return {
    create_rom_symbols = create_rom_symbols,
    create_ram_symbols = create_ram_symbols,
    create_symbols = create_symbols,
    get_memory_area = get_memory_area,
    add_replacement_symbol = add_replacement_symbol,
    set_op_symbol = set_op_symbol,
    add_comment_symbol = add_comment_symbol,
    add_label_symbol = add_label_symbol,
    add_region_symbol = add_region_symbol,
    get_region_symbols = get_region_symbols,
    read_symbols = read_symbols,
}
