local bank_module = require("beast/rom/bank")

local create_bank = bank_module.create_bank
local read_bank = bank_module.read_bank

local function create_rom()
   return {
      nbanks = 0,
      banks = {}
   }
end

local function read_rom(rom, file)
   while true do
      local bank = create_bank()
      read_bank(bank, file)

      if bank.size == 0 then
         break
      end

      rom.banks[rom.nbanks] = bank
      rom.nbanks = rom.nbanks + 1
   end
end

return {
   create_rom = create_rom,
   read_rom = read_rom
}
