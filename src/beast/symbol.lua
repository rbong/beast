local function create_line_reader(line)
   return {
      index = 1,
      line = line,
      len = #line
   }
end

local function read_pattern(reader, pattern, offset)
   local _, pattern_end, group = reader.line:find(pattern, reader.index)
   if pattern_end then
      pattern_end = pattern_end + 1
      reader.index = pattern_end + (offset or 0)
   end
   return pattern_end, group
end

local function read_hex_pattern(reader, pattern, offset)
   local pattern_end, group = read_pattern(reader, pattern, offset)
   if group then
      group = tonumber(group, 16)
   end
   return pattern_end, group
end

local function read_rest(reader)
   return reader.len, reader.line:sub(reader.index)
end

local function reader_has_remaining(reader)
   return reader.index ~= reader.len
end

local function create_rom_symbols(bank_num)
   return {
      labels = {},
      comments = {},
      -- TODO: specify duplicate regions/replacements not allowed
      regions = {},
      _regions_list = {},
      replacements = {},
      operands = {},
      bank_num = bank_num,
      is_ram = false,
      is_rom = true
   }
end

local function create_ram_symbols(bank_num)
   return {
      labels = {},
      comments = {},
      bank_num = bank_num,
      is_rom = false,
      is_ram = true
   }
end

local function create_symbols(options)
   return {
      rom_banks = {},
      sram = create_ram_symbols(),
      wram_banks = {},
      hram = create_ram_symbols(),
      options = options or {}
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

local function set_left_op_symbol(sym, bank_num, address, value)
   local mem = get_memory_area(sym, bank_num, address)
   if mem.is_ram then
      error(string.format("Attempted to add left operand at RAM target: %x:%x", bank_num, address))
   end

   if mem.operands[address] then
      mem.operands[address].l_op = value
   else
      mem.operands[address] = { l_op = value }
   end
end

local function set_right_op_symbol(sym, bank_num, address, value)
   local mem = get_memory_area(sym, bank_num, address)
   if mem.is_ram then
      error(string.format("Attempted to add right operand at RAM target: %x:%x", bank_num, address))
   end

   if mem.operands[address] then
      mem.operands[address].r_op = value
   else
      mem.operands[address] = { r_op = value }
   end
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

   return function ()
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

local function _read_replacement(sym, reader, bank_num, address)
   local size_end, size = read_hex_pattern(reader, "^:(%x+)")
   if not size_end then
      return
   end

   local space_end = read_pattern(reader, "^%s+")
   if not space_end and reader_has_remaining(reader) then
      -- Unrecognized data after size
      return
   end


   local _, body = read_rest(reader)
   add_replacement_symbol(sym, bank_num, address, size, body or "")
end

local function _read_left_op(sym, reader, bank_num, address)
   local space_end = read_pattern(reader, "^%s+")
   if not space_end and reader_has_remaining(reader) then
      -- Unrecognized data after l_op
      return
   end

   local _, body = read_rest(reader)
   set_left_op_symbol(sym, bank_num, address, body or "")
end

local function _read_right_op(sym, reader, bank_num, address)
   local space_end = read_pattern(reader, "^%s+")
   if not space_end and reader_has_remaining(reader) then
      -- Unrecognized data after l_op
      return
   end

   local _, body = read_rest(reader)
   set_right_op_symbol(sym, bank_num, address, body or "")
end

local function _read_comment(sym, reader, bank_num, address)
   local space_end = read_pattern(reader, "^%s+")
   if not space_end and reader_has_remaining(reader) then
      -- Unrecognized data after address
      return
   end

   local _, body = read_rest(reader)
   add_comment_symbol(sym, bank_num, address, body or "")
end

local function _read_region(sym, reader, bank_num, address, region_type)
   local size_end, size = read_hex_pattern(reader, "^:(%x+)$")
   if not size_end then
      -- Size is required
      return
   end
   add_region_symbol(sym, bank_num, address, region_type, size)
end

local function _read_line(sym, line)
   local reader = create_line_reader(line)

   local comment_end = read_pattern(reader, "^;;%s+")

   local bank_end, bank_num = read_hex_pattern(reader, "^(%x%x):", -1)
   if not bank_end then
      return
   end

   local address_end, address = read_hex_pattern(reader, "^:(%x%x%x%x)")
   if not address_end then
      return
   end

   if comment_end then
      local comment_type_end, comment_type = read_pattern(reader, "^:([^%s:]+)")

      if comment_type == "replace" then
         _read_replacement(sym, reader, bank_num, address)
      elseif comment_type == "l_op" then
         _read_left_op(sym, reader, bank_num, address)
      elseif comment_type == "r_op" then
         _read_right_op(sym, reader, bank_num, address)
      elseif comment_type_end then
         -- Unknown comment type
         return
      else
         _read_comment(sym, reader, bank_num, address)
      end
   else
      local space_end = read_pattern(reader, "^%s+")
      if not space_end then
         -- Unrecognized data after address or no label
         return
      end

      local label_end, label = read_pattern(reader, "^([^%s:]+)")

      if not label_end then
         -- Unlabeled line
         return
      elseif label == ".code" or label == ".data" or label == ".text" then
         _read_region(sym, reader, bank_num, address, label:sub(2))
      else
         -- Add plain label
         add_label_symbol(sym, bank_num, address, label)
      end
   end
end

local function read_symbols(sym, file)
   for line in file:lines() do
      _read_line(sym, line)
   end

   -- Check regions for overlapping
   if not sym.options.no_warn_overlaps then
      for bank_num, bank in pairs(sym.rom_banks) do
         local regions = bank.regions

         for address, region in pairs(regions) do
            for i = address + 1, address + region.size - 1 do
               local conflict = regions[i]

               if conflict then
                  io.stderr:write(string.format(
                        "Warning: detected region overlap between %02x:%04x:%04x .%s and %02x:%04x:%04x .%s\n",
                        bank_num,
                        address,
                        region.size,
                        region.region_type,
                        bank_num,
                        i,
                        conflict.size,
                        conflict.region_type
                     ))
               end
            end
         end
      end
   end
end

return {
   create_symbols = create_symbols,
   get_memory_area = get_memory_area,
   add_replacement_symbol = add_replacement_symbol,
   set_left_op_symbol = set_left_op_symbol,
   set_right_op_symbol = set_right_op_symbol,
   add_comment_symbol = add_comment_symbol,
   add_label_symbol = add_label_symbol,
   add_region_symbol = add_region_symbol,
   get_region_symbols = get_region_symbols,
   read_symbols = read_symbols
}
