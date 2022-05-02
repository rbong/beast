local symbol = require("beast/symbol")

local create_symbols = symbol.create_symbols
local create_rom_symbols = symbol.create_rom_symbols
local create_ram_symbols = symbol.create_ram_symbols
local get_region_symbols = symbol.get_region_symbols

local parse_next_instruction = require("beast/instruction").parse_next_instruction

-- TODO: add option to disable auto code detection
-- TODO: code regions being treated as entrypoints means region overlapping is desirable, disable overlap warnings and account for this

function get_rst_instruction_handler(target_address)
   return function (bank, jump_call_locations, context)
      -- TODO: add RST symbol

      if context[0x00][target_address] then
         return
      end
      jump_call_locations[0x00][target_address] = true
   end
end

function call_instruction_handler(bank, jump_call_locations, context, instruction)
   local target_address = instruction.data

   -- TODO: detect ROM location
   if target_address >= 0x4000 and bank.bank_num == 0 then
      return
   end

   local bank_num = target_address < 0x4000 and 0 or bank.bank_num

   -- TODO: add call symbol

   if context[bank_num][target_address] then
      return
   end

   jump_call_locations[bank_num][target_address] = true
end

function jump_instruction_handler(bank, jump_call_locations, context, instruction)
   local target_address = instruction.data

   -- TODO: detect ROM location
   if target_address >= 0x4000 and bank.bank_num == 0 then
      return
   end

   local bank_num = target_address < 0x4000 and 0 or bank.bank_num

   -- TODO: add jump symbol

   if context[bank_num][target_address] then
      return
   end

   jump_call_locations[bank_num][target_address] = true
end

local instruction_handlers = {
   ["rst $00"] = get_rst_instruction_handler(0x0000),
   ["rst $08"] = get_rst_instruction_handler(0x0008),
   ["rst $10"] = get_rst_instruction_handler(0x0010),
   ["rst $18"] = get_rst_instruction_handler(0x0018),
   ["rst $20"] = get_rst_instruction_handler(0x0020),
   ["rst $28"] = get_rst_instruction_handler(0x0028),
   ["rst $30"] = get_rst_instruction_handler(0x0030),
   ["rst $38"] = get_rst_instruction_handler(0x0038),
   ["call n16"] = call_instruction_handler,
   ["call c, n16"] = call_instruction_handler,
   ["call z, n16"] = call_instruction_handler,
   ["call nc, n16"] = call_instruction_handler,
   ["call nz, n16"] = call_instruction_handler,
   ["jp n16"] = jump_instruction_handler,
   ["jp c, n16"] = jump_instruction_handler,
   ["jp z, n16"] = jump_instruction_handler,
   ["jp nc, n16"] = jump_instruction_handler,
   ["jp nz, n16"] = jump_instruction_handler,
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

local function parse_bank_code_regions(bank, jump_call_locations, context)
   local bank_num = bank.bank_num
   local instructions = bank.instructions
   local bank_context = context[bank_num]

   for region in get_region_symbols(bank.symbols, bank_num) do
      if region.region_type == "code" then
         local address = region.address
         local remaining = region.size

         -- Don't parse regions that have already been parsed
         if not bank_context[address] then
            bank_context[address] = {}

            while remaining > 0 do
               local index = address % 0x4000

               -- Parse instruction
               local instruction = parse_next_instruction(bank.data, index, remaining)

               if instruction then
                  -- Handle instruction

                  instructions[address] = instruction

                  -- Iterate loop variables
                  local size = instruction.size or 1
                  remaining = remaining - size
                  address = address + size

                  -- Run instruction handler if available
                  local instruction_handler = instruction_handlers[instruction.instruc]
                  if instruction_handler then
                     instruction_handler(bank, jump_call_locations, context, instruction, address)
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

local function parse_bank_jump_call_location(bank, jump_call_locations, context, address)
   local bank_num = bank.bank_num
   local instructions = bank.instructions
   local regions = bank.symbols.rom_banks[bank_num].regions

   context[bank_num][address] = {}

   while true do
      local index = address % 0x4000

      -- Check for data region - terminates call/jump location
      -- TODO: optional warn
      local region = regions[address]
      if region then
         local region_type = region.region_type
         if region_type == "data" or region_type == "text" then
            break
         end
      end

      -- Parse address
      local instruction = parse_next_instruction(bank.data, index)
      if not instruction then
         return
      end

      -- Record instruction
      instructions[address] = instruction

      -- Run instruction handler if available
      local instruction_handler = instruction_handlers[instruction.instruc]
      if instruction_handler then
         instruction_handler(bank, jump_call_locations, context, instruction, adddress)
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
   -- Read bank data
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

   -- Call/jump locations
   local jump_call_locations = {
      [0x00] = {
         -- TODO: interrupts?
         -- 00:0150 - Entrypoint
         [0x0150] = true
      }
   }

   -- Code execution metadata
   local context = {
      [0x00] = {}
   }

   -- Initialize bank 0 symbols
   local rom_banks = rom.symbols.rom_banks
   local wram_banks = rom.symbols.wram_banks
   if not rom_banks[0x00] then
      rom_banks[0x00] = create_rom_symbols()
   end
   if not wram_banks[0x00] then
      wram_banks[0x00] = create_ram_symbols()
   end

   -- Initialize metadata
   for bank_num = 1, rom.nbanks - 1 do
      jump_call_locations[bank_num] = {}
      context[bank_num] = {}
      if not rom_banks[bank_num] then
         rom_banks[bank_num] = create_rom_symbols()
      end
      if not wram_banks[bank_num] then
         wram_banks[bank_num] = create_ram_symbols()
      end
   end

   -- Parse code regions
   for bank_num = 0, rom.nbanks - 1 do
      parse_bank_code_regions(rom.banks[bank_num], jump_call_locations, context)
   end

   -- Parse call/jump locations
   local has_new_code_locations = true
   while has_new_code_locations do
      has_new_code_locations = false

      for bank_num, bank_jump_call_locations in pairs(jump_call_locations) do
         -- Clear call/jump locations for next loop
         jump_call_locations[bank_num] = {}

         for address in pairs(bank_jump_call_locations) do
            parse_bank_jump_call_location(rom.banks[bank_num], jump_call_locations, context, address)
            has_new_code_locations = true
         end
      end
   end
end

return {
   create_bank = create_bank,
   create_rom = create_rom,
   read_rom = read_rom
}
