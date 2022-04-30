local create_symbols = require("beast/symbol").create_symbols

local read_next_instruction = require("beast/rom/instruction").read_next_instruction

local function create_bank(bank_num, symbols, options)
   return {
      bank_num = bank_num,
      size = 0,
      instructions = {},
      symbols = symbols or create_symbols(),
      options = options or {}
   }
end

local function read_bank(bank, file)
   local remaining = 0x4000
   while remaining do
      local instruction = read_next_instruction(file, remaining)
      -- TODO: handle nil instructions properly
      if instruction == nil then
         break
      end

      table.insert(bank.instructions, instruction)
      remaining = remaining - (instruction.size or 1)
   end
   bank.size = 0x4000 - remaining
end

return {
   create_bank = create_bank,
   read_bank = read_bank
}
