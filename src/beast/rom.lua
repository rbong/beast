local bank = require("beast/rom/bank")
local instruction = require("beast/rom/instruction")
local operand = require("beast/rom/operand")
local rom = require("beast/rom/rom")

return {
   create_bank = bank.create_bank,
   read_bank = bank.read_bank,
   create_instruction = instruction.create_instruction,
   instructions = instruction.instructions,
   read_next_instruction = instruction.read_next_instruction,
   create_operand = operand.create_operand,
   create_processor_register_operand = operand.create_processor_register_operand,
   create_processor_register_set_operand = operand.create_processor_register_set_operand,
   create_processor_register_set_reference_operand = operand.create_processor_register_set_reference_operand,
   create_condition_operand = operand.create_condition_operand,
   create_vector_operand = operand.create_vector_operand,
   create_dynamic_octet_operand = operand.create_dynamic_octet_operand,
   create_dynamic_byte_operand = operand.create_dynamic_byte_operand,
   operands = operand.operands,
   create_rom = rom.create_rom,
   read_rom = rom.read_rom
}
