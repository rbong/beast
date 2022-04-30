local create_symbols = require("beast/symbol").create_symbols

local parse_next_instruction = require("beast/rom/instruction").parse_next_instruction

local function create_bank(bank_num, symbols, options)
   return {
      bank_num = bank_num,
      size = 0,
      data = "",
      instructions = {},
      symbols = symbols or create_symbols(),
      options = options or {}
   }
end

local function read_bank(bank, file)
   bank.data = file:read(0x4000)
   bank.size = bank.data and #bank.data or 0
end

local function parse_bank_instructions(bank, address, max)
   local instructions = bank.instructions
   local nread = 0

   max = max or bank.size

   while max > 0 do
      local instruction = parse_next_instruction(bank.data, address, max)

      -- -- TODO: stop on non-instructions
      -- if not instruction then
      --    return nread
      -- end

      -- TODO: read jump locations
      -- TODO: end on unconditional jump/return

      local size = 1

      if instruction then
         instructions[address] = instruction
         size = instruction.size or 1
      end

      address = address + size
      max = max - size
      nread = nread + 1
   end

   return nread
end

return {
   create_bank = create_bank,
   read_bank = read_bank,
   parse_bank_instructions = parse_bank_instructions
}
