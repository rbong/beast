local bank = require("beast/rom/bank")
local instruction = require("beast/rom/instruction")
local rom = require("beast/rom/rom")

return {
   create_bank = bank.create_bank,
   read_bank = bank.read_bank,
   read_next_instruction = instruction.read_next_instruction,
   create_rom = rom.create_rom,
   read_rom = rom.read_rom
}
