local read_next_instruction = require("beast/rom/instruction").read_next_instruction

local function create_bank()
   return {
      size = 0,
      instructions = {}
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
      remaining = remaining - instruction.size
   end
   bank.size = 0x4000 - remaining
end

return {
   create_bank = create_bank,
   read_bank = read_bank
}
