-- TODO: add support for all instructions

local function create_formatter()
   return {}
end

local function format_bank_header(formatter, bank_num)
   if bank_num == 0 then
      return "SECTION \"ROM Bank $000\", ROM0[$0000]"
   end

   return string.format(
      "SECTION \"ROM Bank $%03x\", ROMX[$%04x], BANK[$%03x]",
      bank_num,
      bank_num * 0x4000,
      bank_num)
end

local function format_op(formatter, op)
   if not op then
      return
   end

   if op.is_register or op.is_condition then
      return op.value
   end

   if op.is_vector then
      return string.format("$%02x", op.value)
   end

   if op.is_dynamic then
      if op.size == 1 then
         return string.format("$%02x", op.value)
      end

      if op.size == 2 then
         return string.format("$%04x", op.value)
      end
   end

   -- TODO: better error handling
   error("Unrecognized operand")
end

-- TODO: handle more complex data
local function format_data(formatter, instructions, instruction_index)
   return 1, string.format("db $%02x", instructions[instruction_index].data[1])
end

local function format_instructions(formatter, instructions, instruction_index)
   local instruction = instructions[instruction_index]

   local code = instruction.code

   if instruction.is_data then
      return format_data(formatter, instructions, instruction_index)
   end

   local l_op = instruction.l_op
   local r_op = instruction.r_op

   if r_op and not l_op then
      -- TODO: better error handling
      error("Got right operand but no left operand")
   end

   local l_op_value = format_op(formatter, instruction.l_op)
   local r_op_value = format_op(formatter, instruction.r_op)

   if r_op then
      return 1, code .. " " .. l_op_value .. ", " .. r_op_value
   end

   if l_op then
      return 1, code .. " " .. l_op_value
   end

   return 1, code
end

-- TODO: rename
local function create_asm(formatter, base_path, rom, sym)
   -- TODO: create base if it does not exist

   -- TODO: better error handling
   if not base_path then
      error("No base path")
   end

   for bank_num, bank in pairs(rom.banks) do
      local path = string.format("%s/bank_%03x.asm", base_path, bank_num)
      local file = io.open(path, "wb")

      file:write(format_bank_header(formatter, bank_num))
      file:write("\n\n")

      local instructions = bank.instructions
      local instruction_index = 1
      local ninstructions = #instructions

      while instruction_index <= ninstructions do
         local instructions_read, instruction_values = format_instructions(formatter, instructions, instruction_index)

         if instructions_read == 1 then
            file:write(instruction_values)
            file:write("\n")
         else
            for _, instruction_value in pairs(instruction_values) do
               file:write(instruction_value)
               file:write("\n")
            end
         end

         instruction_index = instruction_index + instructions_read
      end

      file:close()
   end
end

return {
   create_formatter = create_formatter,
   format_bank_header = format_bank_header,
   format_op = format_op,
   format_instructions = format_instructions,
   create_asm = create_asm
}
