local line_reader = require("beast/symbol/line_reader")
local symbol = require("beast/symbol/symbol")

-- TODO: increase number of private functions

return {
   create_line_reader = line_reader.create_line_reader,
   read_pattern = line_reader.read_pattern,
   read_hex_pattern = line_reader.read_hex_pattern,
   read_rest = line_reader.read_rest,
   has_remaining = line_reader.has_remaining,
   create_symbols = symbol.create_symbols,
   get_memory_area = symbol.get_memory_area,
   add_replacement_symbol = symbol.add_replacement_symbol,
   set_left_op_symbol = symbol.set_left_op_symbol,
   set_right_op_symbol = symbol.set_right_op_symbol,
   add_comment_symbol = symbol.add_comment_symbol,
   add_label_symbol = symbol.add_label_symbol,
   add_region_symbol = symbol.add_region_symbol,
   get_region_symbols = symbol.get_region_symbols,
   read_symbols = symbol.read_symbols
}
