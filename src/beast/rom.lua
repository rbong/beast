local instruction = require("beast/rom/instruction")
local rom = require("beast/rom/rom")

return {
   parse_next_instruction = instruction.parse_next_instruction,
   create_rom = rom.create_rom,
   read_rom = rom.read_rom
}
