local RomSymbols = {}

RomSymbols.new = function(self, bank_num)
    local rom_symbols = {
        labels = {},
        comments = {},
        -- TODO: warn when overlapping regions are specified
        regions = {},
        _regions_list = {},
        -- TODO: warn when overlapping replacements are specified
        replacements = {},
        operands = {},
        -- TODO: warn when overlapping files are specified
        files = {},
        bank_num = bank_num,
        is_ram = false,
        is_rom = true,
    }

    setmetatable(rom_symbols, self)
    self.__index = self

    return rom_symbols
end

local RamSymbols = {}

RamSymbols.new = function(self, bank_num)
    local ram_symbols = {
        labels = {},
        comments = {},
        bank_num = bank_num,
        is_rom = false,
        is_ram = true,
    }

    setmetatable(ram_symbols, self)
    self.__index = self

    return ram_symbols
end

local Symbols = {}

Symbols.new = function(self, options)
    local sym = {
        rom_banks = {},
        sram_banks = {},
        wram_banks = {},
        hram = RamSymbols:new(),
        options = options or {},
    }

    setmetatable(sym, self)
    self.__index = self

    return sym
end

Symbols.get_init_rom_bank = function(self, bank_num)
    if not self.rom_banks[bank_num] then
        self.rom_banks[bank_num] = RomSymbols:new(bank_num)
    end
    return self.rom_banks[bank_num]
end

Symbols.get_init_sram_bank = function(self, bank_num)
    if not self.sram_banks[bank_num] then
        self.sram_banks[bank_num] = RamSymbols:new(bank_num)
    end
    return self.sram_banks[bank_num]
end

Symbols.get_init_wram_bank = function(self, bank_num, address)
    if address ~= nil and address >= 0xd000 and bank_num == 0 then
        bank_num = 1
    end
    if not self.wram_banks[bank_num] then
        self.wram_banks[bank_num] = RamSymbols:new(bank_num)
    end
    return self.wram_banks[bank_num]
end

Symbols.get_relative_memory_area = function(self, source_bank_num, target_address)
    if target_address < 0x8000 then
        if source_bank_num == 0 and target_address >= 0x8000 then
            -- Can't determine target bank from bank 0 at this time
            return nil
        end
        return self:get_init_rom_bank(source_bank_num)
    elseif target_address < 0xc000 then
        -- Unable to determine SRAM target bank currently
        return nil
    elseif target_address < 0xe000 then
        -- Unable to determine WRAM target bank currently
        return nil
    elseif target_address < 0xffff then
        return self.hram
    end
end

Symbols.get_memory_area_unsafe = function(self, bank_num, address)
    if address < 0x8000 then
        return self:get_init_rom_bank(bank_num)
    elseif address < 0xc000 then
        return self:get_init_sram_bank(bank_num)
    elseif address < 0xe000 then
        return self:get_init_wram_bank(bank_num, address)
    elseif address < 0xffff then
        return self.hram
    end
end

Symbols.get_memory_area = function(self, bank_num, address)
    -- Check bank
    if bank_num < 0 then
        error(string.format("Invalid bank target: %d", bank_num))
    end

    -- Check address
    if address < 0 then
        error(string.format("Invalid address target: %d", address))
    end
    if address > 0xffff then
        error(string.format("Invalid address target: %02x:%x", bank_num, address))
    end
    if address >= 0xfea0 and address < 0xff00 then
        error(string.format("Invalid address target: %02x:%04x", bank_num, address))
    end

    -- Check ROM bank
    if address < 0x4000 and bank_num ~= 0 then
        error(string.format("Invalid ROM target: %02x:%04x", bank_num, address))
    end
    if address >= 0x4000 and address < 0x8000 and bank_num == 0 then
        error(string.format("Invalid ROM target: %02x:%04x", bank_num, address))
    end

    -- Check for VRAM target
    if address >= 0x8000 and address < 0xa000 then
        error(string.format("Unsupported target in VRAM: %02x:%04x", bank_num, address))
    end

    -- Check WRAM bank
    if address >= 0xc000 and address < 0xd000 and bank_num ~= 0 then
        error(string.format("Invalid WRAM target: %02x:%04x", bank_num, address))
    end

    -- Check for ECHO RAM target
    if address >= 0xe000 and address < 0xfe00 then
        error(string.format("Unsupported target in ECHO RAM: %02x:%04x", bank_num, address))
    end

    -- Check for OAM target
    if address >= 0xfe00 and address < 0xfea0 then
        error(string.format("Unsupported target in OAM: %02x:%04x", bank_num, address))
    end

    -- Check for IO register target
    if address >= 0xff00 and address < 0xff80 then
        error(string.format("Unsupported target in IO registers: %02x:%04x", bank_num, address))
    end

    -- Check HRAM bank
    if address >= 0xff80 and address < 0xffff and bank_num ~= 0 then
        error(string.format("Invalid HRAM target: %02x:%04x", bank_num, address))
    end

    -- Check for IE target
    if address == 0xffff then
        error(string.format("Unsupported target IE: %02x:%04x", bank_num, address))
    end

    return self:get_memory_area_unsafe(bank_num, address)
end

Symbols.add_replacement_symbol = function(self, bank_num, address, size, body)
    local mem = self:get_memory_area(bank_num, address)
    if mem.is_ram then
        error(string.format("Attempted to add replacement at RAM target: %02x:%04x", bank_num, address))
    end

    mem.replacements[address] = { size = size, body = body }
end

Symbols.set_op_symbol = function(self, bank_num, address, value)
    local mem = self:get_memory_area(bank_num, address)
    if mem.is_ram then
        error(string.format("Attempted to add operand at RAM target: %02x:%04x", bank_num, address))
    end

    mem.operands[address] = value
end

Symbols.set_file_symbol = function(self, bank_num, address, size, file_name)
    local mem = self:get_memory_area(bank_num, address)
    if mem.is_ram then
        error(string.format("Attempted to add file at RAM target: %02x:%04x", bank_num, address))
    end

    mem.files[address] = { size = size, file_name = file_name }
end

Symbols.add_comment_symbol = function(self, bank_num, address, body)
    local comments = self:get_memory_area(bank_num, address).comments

    if comments[address] then
        table.insert(comments[address], body)
    else
        comments[address] = { body }
    end
end

Symbols.add_label_symbol = function(self, bank_num, address, body)
    local labels = self:get_memory_area(bank_num, address).labels

    if labels[address] then
        table.insert(labels[address], body)
    else
        labels[address] = { body }
    end
end

Symbols.add_region_symbol = function(self, bank_num, address, region_type, size)
    local mem = self:get_memory_area(bank_num, address)
    if mem.is_ram then
        error(string.format("Attempted to add region to RAM target: %02x:%04x", bank_num, address))
    end

    local region = { region_type = region_type, address = address, size = size }
    mem.regions[address] = region
    -- Add the region to a list so it can be iterated through
    table.insert(mem._regions_list, region)
end

Symbols.get_region_symbols = function(self, bank_num)
    local i = 1
    local regions
    local regions_list

    if self.rom_banks[bank_num] then
        regions = self.rom_banks[bank_num].regions
        regions_list = self.rom_banks[bank_num]._regions_list
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

Symbols.parse_comment = function(self, bank_num, address, body)
    -- Trim first whitespace on body
    body = body:gsub("^%s", "")
    self:add_comment_symbol(bank_num, address, body)
end

Symbols.parse_replacement = function(self, bank_num, address, replace_opts, body)
    local _, _, size = replace_opts:find("^:(%x+)$")

    if size == nil then
        -- Unreadable size opt
        return
    end

    -- Parse size
    size = tonumber(size, 16)

    -- Trim leading whitespace on body
    body = body:gsub("^%s*", "")

    self:add_replacement_symbol(bank_num, address, size, body)
end

Symbols.parse_op = function(self, bank_num, address, op_opts, body)
    if op_opts ~= "" then
        -- Unrecognized data after :op
        return
    end

    -- Trim leading whitespace on body
    body = body:gsub("^%s*", "")

    self:set_op_symbol(bank_num, address, body)
end

Symbols.parse_file = function(self, bank_num, address, file_opts, body)
    local _, _, size = file_opts:find("^:(%x+)$")

    if size == nil then
        -- Unreadable size opt
        return
    end

    -- Parse size
    size = tonumber(size, 16)

    -- Trim leading whitespace on body
    body = body:gsub("^%s*", "")

    if body == "" then
        -- No filename
        return
    end

    self:set_file_symbol(bank_num, address, size, body)
end

Symbols.parse_region = function(self, bank_num, address, label, region_opts)
    -- Trim leading "." from label to get region type
    local region_type = label:gsub("^%.", "")

    local _, _, size = region_opts:find("^:(%x+)$")

    if size == nil then
        -- Unreadable size opt
        return
    end

    size = tonumber(size, 16)

    self:add_region_symbol(bank_num, address, region_type, size)
end

Symbols.parse_commented_line = function(self, bank_num, address, opts, body)
    if opts == "" then
        self:parse_comment(bank_num, address, body)
        return
    end

    -- Break the opts into groups
    local _, _, symbol_type, symbol_type_opts = opts:find("^:([^:]*)(.*)")

    if symbol_type == "replace" then
        self:parse_replacement(bank_num, address, symbol_type_opts, body)
    elseif symbol_type == "op" then
        self:parse_op(bank_num, address, symbol_type_opts, body)
    elseif symbol_type == "file" then
        self:parse_file(bank_num, address, symbol_type_opts, body)
    end
end

Symbols.parse_uncommented_line = function(self, bank_num, address, opts, body)
    local _, _, label, label_opts = body:find("^%s*([^%s:]+)(.*)")

    if label == nil then
        return
    end

    if label == ".code" or label == ".data" or label == ".text" then
        self:parse_region(bank_num, address, label, label_opts)
    elseif label_opts ~= "" then
        -- Extra label opts, unknown label type
        return
    else
        -- Add plain label
        self:add_label_symbol(bank_num, address, label)
    end
end

Symbols.parse_line = function(self, line)
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
        self:parse_commented_line(bank_num, address, opts, body)
    elseif leading_semicolons == "" then
        -- The line does not start with any semicolons
        self:parse_uncommented_line(bank_num, address, opts, body)
    end
end

Symbols.read_symbols = function(self, file)
    for line in file:lines() do
        self:parse_line(line)
    end
end

return {
    RomSymbols = RomSymbols,
    RamSymbols = RamSymbols,
    Symbols = Symbols,
}
