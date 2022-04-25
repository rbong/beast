local definition = require("beast/symbol/definition")
local line_reader = require("beast/symbol/line_reader")
local mem_area = require("beast/symbol/memory_area")
local symbol = require("beast/symbol/symbol")

-- TODO: increase number of private functions

return {
   create_region_definition = definition.create_region_definition,
   create_replacement_definition = definition.create_replacement_definition,
   create_operand_definitions = definition.create_operand_definitions,
   set_left_op_definition = definition.set_left_op_definition,
   set_right_op_definition = definition.set_right_op_definition,
   create_definition_collection = definition.create_definition_collection,
   add_definition = definition.add_definition,
   insert_definition = definition.insert_definition,
   get_definition = definition.get_definition,
   create_line_reader = line_reader.create_line_reader,
   read_pattern = line_reader.read_pattern,
   read_hex_pattern = line_reader.read_hex_pattern,
   read_rest = line_reader.read_rest,
   has_remaining = line_reader.has_remaining,
   create_symbols_memory_area = mem_area.create_symbols_memory_area,
   add_mem_area_label = mem_area.add_mem_area_label,
   add_mem_area_comment = mem_area.add_mem_area_comment,
   create_rom_symbols = mem_area.create_rom_symbols,
   set_rom_area_region = mem_area.set_rom_area_region,
   add_rom_area_replacement = mem_area.add_rom_area_replacement,
   set_rom_area_left_op = mem_area.set_rom_area_left_op,
   set_rom_area_right_op = mem_area.set_rom_area_right_op,
   create_ram_symbols = mem_area.create_ram_symbols,
   create_symbols = symbol.create_symbols,
   get_memory_area = symbol.get_memory_area,
   add_replacement_symbol = symbol.add_replacement_symbol,
   set_left_op_symbol = symbol.set_left_op_symbol,
   set_right_op_symbol = symbol.set_right_op_symbol,
   add_comment_symbol = symbol.add_comment_symbol,
   add_label_symbol = symbol.add_label_symbol,
   add_region_symbol = symbol.add_region_symbol,
   read_symbols = symbol.read_symbols
}
