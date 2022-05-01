local symbol = require("beast/symbol")

local create_symbols = symbol.create_symbols
local get_region_symbols = symbol.get_region_symbols

local parse_next_instruction = require("beast/instruction").parse_next_instruction

-- TODO: add option to disable auto code detection

function get_rst_updater(address)
   return function (bank, code_locations, parsed)
      -- TODO: add RST symbol

      if parsed[0][address] then
         return
      end
      code_locations[0][address] = true
   end
end

function call_updater(bank, code_locations, parsed, instruction)
   local address = instruction.data

   -- TODO: detect ROM location
   if address >= 0x4000 and bank.bank_num == 0 then
      return
   end

   local bank_num = address < 0x4000 and 0 or bank.bank_num

   -- TODO: add call symbol

   if parsed[bank_num][address] then
      return
   end

   code_locations[bank_num][address] = true
end

function jump_updater(bank, code_locations, parsed, instruction)
   local address = instruction.data

   -- TODO: detect ROM location
   if address >= 0x4000 and bank.bank_num == 0 then
      return
   end

   local bank_num = address < 0x4000 and 0 or bank.bank_num

   -- TODO: add jump symbol

   if parsed[bank_num][address] then
      return
   end

   code_locations[bank_num][address] = true
end

local instruction_updaters = {
   ["rst $00"] = get_rst_updater(0x0000),
   ["rst $08"] = get_rst_updater(0x0008),
   ["rst $10"] = get_rst_updater(0x0010),
   ["rst $18"] = get_rst_updater(0x0018),
   ["rst $20"] = get_rst_updater(0x0020),
   ["rst $28"] = get_rst_updater(0x0028),
   ["rst $30"] = get_rst_updater(0x0030),
   ["rst $38"] = get_rst_updater(0x0038),
   ["call n16"] = call_updater,
   ["call c, n16"] = call_updater,
   ["call z, n16"] = call_updater,
   ["call nc, n16"] = call_updater,
   ["call nz, n16"] = call_updater,
   ["jp n16"] = jump_updater,
   ["jp c, n16"] = jump_updater,
   ["jp z, n16"] = jump_updater,
   ["jp nc, n16"] = jump_updater,
   ["jp nz, n16"] = jump_updater,
   -- TODO: relative jumps
}

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

local function parse_bank_code_regions(bank, code_locations, parsed)
   local bank_parsed = parsed[bank.bank_num]
   local instructions = bank.instructions

   for region in get_region_symbols(bank.symbols, bank.bank_num) do
      if region.region_type == "code" then
         local address = region.address
         local remaining = region.size

         -- Don't parse regions that have already been parsed
         if not bank_parsed[address] then
            while remaining > 0 do
               -- Parse instruction
               local instruction = parse_next_instruction(bank.data, address, remaining)
               bank_parsed[address] = true

               if instruction then
                  -- Handle instruction

                  instructions[address] = instruction

                  -- Iterate loop variables
                  local size = instruction.size or 1
                  remaining = remaining - size
                  address = address + size

                  -- Run updater if available
                  local updater = instruction_updaters[instruction.instruc]
                  if updater then
                     updater(bank, code_locations, parsed, instruction)
                  end
               else
                  -- Handle data

                  -- Iterate loop variables
                  -- Data inside of code regions is treated as 1 byte large
                  remaining = remaining - 1
                  address = address + 1
               end
            end
         end
      end
   end
end

local function parse_bank_code_location(bank, code_locations, parsed, address)
   local bank_parsed = parsed[bank.bank_num]
   local instructions = bank.instructions
   local regions = (bank.symbols.rom_banks[bank.bank_num] or {}).regions or {}

   while not regions[address] do
      -- Parse address
      local instruction = parse_next_instruction(bank.data, address)
      bank_parsed[address] = true
      if not instruction then
         return
      end

      -- Record instruction
      instructions[address] = instruction

      -- Run updater if available
      local updater = instruction_updaters[instruction.instruc]
      if updater then
         updater(bank, code_locations, parsed, instruction)
      end

      -- End parsing if instruction ends code
      if instruction.code_end then
         return
      end

      -- Iterate address
      address = address + (instruction.size or 1)
   end
end

local function create_rom(symbols, options)
   return {
      nbanks = 0,
      banks = {},
      symbols = symbols or create_symbols(),
      options = options or {}
   }
end

local function read_rom(rom, file)
   -- Initialize call/jump locations
   local code_locations = {
      [0x00] = {
         -- TODO: interrupts?
         -- Entrypoint
         [0x0150] = true
      }
   }

   -- Previously parsed addresses
   local parsed = {}

   while true do
      local bank_num = rom.nbanks

      -- Read bank
      local bank = create_bank(bank_num, rom.symbols, rom.options)
      read_bank(bank, file)
      if bank.size == 0 then
         break
      end
      rom.banks[bank_num] = bank

      -- Initialize parsing data
      if bank_num > 0 then
         code_locations[bank_num] = {}
      end
      parsed[bank_num] = {}

      parse_bank_code_regions(bank, code_locations, parsed)

      rom.nbanks = bank_num + 1
   end

   local new_code_locations = 1

   -- Parse ROM call/jump locations
   while new_code_locations > 0 do
      new_code_locations = 0

      for bank_num, addresses in pairs(code_locations) do
         code_locations[bank_num] = {}

         for address in pairs(addresses) do
            parse_bank_code_location(rom.banks[bank_num], code_locations, parsed, address)
            new_code_locations = new_code_locations + 1
         end
      end
   end
end

return {
   create_rom = create_rom,
   read_rom = read_rom
}
