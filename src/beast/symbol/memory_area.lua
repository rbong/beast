local definition = require("beast/symbol/definition")

local create_definition_collection = definition.create_definition_collection
local create_region_definition = definition.create_region_definition
local create_operand_definitions = definition.create_operand_definitions
local create_replacement_definition = definition.create_replacement_definition

local add_definition = definition.add_definition
local insert_definition = definition.insert_definition
local get_definition = definition.get_definition

local set_left_op_definition = definition.set_left_op_definition
local set_right_op_definition = definition.set_right_op_definition

-- TODO: disallow local labels for RAM

local function create_symbols_memory_area()
   return {
      labels = create_definition_collection(),
      comments = create_definition_collection()
   }
end

-- TODO: handle duplicate global labels (configurable)

local function add_mem_area_label(mem_area, address, label)
   insert_definition(mem_area.labels, address, label)
end

local function add_mem_area_comment(mem_area, address, comment)
   insert_definition(mem_area.comments, address, comment)
end

local function create_rom_symbols(bank_num)
   return {
      labels = create_definition_collection(),
      comments = create_definition_collection(),
      -- TODO: specify duplicate regions/replacements not allowed
      regions = create_definition_collection(),
      _regions_list = {},
      replacements = create_definition_collection(),
      operands = create_definition_collection(),
      bank_num = bank_num,
      is_ram = false,
      is_rom = true
   }
end

local function set_rom_area_region(rom_area, address, region_type, size)
   add_definition(rom_area.regions, address, create_region_definition(region_type, size))
   -- Add the region to a list so it can be iterated through
   table.insert(rom_area._regions_list, { address, create_region_definition(region_type, size) })
end

local function get_rom_area_regions(rom_area)
   local i = 1
   local regions = rom_area.regions.definitions
   local regions_list = rom_area._regions_list

   return function ()
      local region
      -- Skip over regions that were overwritten
      repeat
         region = regions_list[i]
         i = i + 1
      until not region or regions[region[1]]

      if not region then
         return
      end

      return region[1], region[2]
   end
end

local function add_rom_area_replacement(rom_area, address, size, value)
   add_definition(rom_area.replacements, address, create_replacement_definition(size, value))
end

-- TODO: handle two of the same type of operands at the same address

local function _get_init_rom_area_operands(rom_area, address)
   if not get_definition(rom_area.operands, address) then
      add_definition(rom_area.operands, address, create_operand_definitions())
   end
   return get_definition(rom_area.operands, address)
end

local function set_rom_area_left_op(rom_area, address, l_op)
   set_left_op_definition(_get_init_rom_area_operands(rom_area, address), l_op)
end

local function set_rom_area_right_op(rom_area, address, r_op)
   set_right_op_definition(_get_init_rom_area_operands(rom_area, address), r_op)
end

local function create_ram_symbols(bank_num)
   return {
      labels = create_definition_collection(),
      comments = create_definition_collection(),
      bank_num = bank_num,
      is_rom = false,
      is_ram = true
   }
end

return {
   create_symbols_memory_area = create_symbols_memory_area,
   add_mem_area_label = add_mem_area_label,
   add_mem_area_comment = add_mem_area_comment,
   create_rom_symbols = create_rom_symbols,
   get_rom_area_regions = get_rom_area_regions,
   set_rom_area_region = set_rom_area_region,
   add_rom_area_replacement = add_rom_area_replacement,
   set_rom_area_left_op = set_rom_area_left_op,
   set_rom_area_right_op = set_rom_area_right_op,
   create_ram_symbols = create_ram_symbols
}
