local create_symbols = require("beast/symbol").create_symbols

local bank_module = require("beast/rom/bank")

local create_bank = bank_module.create_bank
local read_bank = bank_module.read_bank
local parse_bank_instructions = bank_module.parse_bank_instructions

local function create_rom(symbols, options)
   return {
      nbanks = 0,
      banks = {},
      symbols = symbols or create_symbols(),
      options = options or {}
   }
end

local function read_rom(rom, file)
   while true do
      local bank_num = rom.nbanks

      local bank = create_bank(bank_num, rom.symbols, rom.options)
      read_bank(bank, file)

      if bank.size == 0 then
         break
      end

      rom.banks[bank_num] = bank
      rom.nbanks = bank_num + 1
   end

   for _, bank in pairs(rom.banks) do
      -- TODO: handle symbols, regions, etc.
      parse_bank_instructions(bank, 0)
   end
end

return {
   create_rom = create_rom,
   read_rom = read_rom
}
