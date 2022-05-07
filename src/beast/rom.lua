local symbol = require("beast/symbol")

local create_symbols = symbol.create_symbols
local create_rom_symbols = symbol.create_rom_symbols
local create_ram_symbols = symbol.create_ram_symbols
local get_region_symbols = symbol.get_region_symbols

local parse_next_instruction = require("beast/instruction").parse_next_instruction

local add_jump_call_location

-- TODO: add option to disable auto code detection
-- TODO: stop adding labels directly and let the formatter handle it

function get_rst_instruction_handler(target_address)
   return function (rom, bank_num, address)
      local labels = rom.symbols.rom_banks[0x00].labels

      if not labels[target_address] then
         labels[target_address] = string.format("rst_%02x", target_address)
      end

      add_jump_call_location(rom, 0x00, target_address, bank_num, address)
   end
end

function call_instruction_handler(rom, bank_num, address, instruction)
   local target_address = instruction.data

   -- TODO: detect ROM location
   if target_address >= 0x4000 and bank_num == 0 then
      return
   end

   local target_bank_num = target_address < 0x4000 and 0 or bank_num

   local labels = rom.symbols.rom_banks[target_bank_num].labels
   if not labels[target_address] then
      labels[target_address] = { string.format("call_%02x_%04x", target_bank_num, target_address) }
   end

   add_jump_call_location(rom, target_bank_num, target_address, bank_num, address)
end

function jump_instruction_handler(rom, bank_num, address, instruction)
   local target_address = instruction.data

   -- TODO: detect ROM location
   if target_address >= 0x4000 and bank_num == 0 then
      return
   end

   local target_bank_num = target_address < 0x4000 and 0 or bank_num

   local rom_symbols = rom.symbols.rom_banks[target_bank_num]
   if rom_symbols then
      local labels = rom_symbols.labels
      if not labels[target_address] then
         labels[target_address] = { string.format("jp_%02x_%04x", target_bank_num, target_address) }
      end
   end

   add_jump_call_location(rom, target_bank_num, target_address, bank_num, address)
end

function relative_jump_instruction_handler(rom, bank_num, address, instruction)
   local target_address = address + instruction.data

   -- TODO: detect ROM location
   if target_address >= 0x4000 and bank_num == 0 then
      return
   end

   local labels = rom.symbols.rom_banks[bank_num].labels
   if not labels[target_address] then
      labels[target_address] = { string.format("jr_%02x_%04x", bank_num, target_address) }
   end

   add_jump_call_location(rom, bank_num, target_address, bank_num, address)
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
   ["jr e8"] = relative_jump_instruction_handler,
   ["jr c, e8"] = relative_jump_instruction_handler,
   ["jr z, e8"] = relative_jump_instruction_handler,
   ["jr nc, e8"] = relative_jump_instruction_handler,
   ["jr nz, e8"] = relative_jump_instruction_handler,
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

local function create_rom(symbols, options)
   local rom = {
      nbanks = 0,
      banks = {},
      symbols = symbols or create_symbols(),
      options = options or {},
      jump_call_locations = {
         [0x00] = {}
      },
      unparsed_jump_call_locations = {
         [0x00] = {}
      },
      context = {
         [0x00] = {}
      }
   }

   -- Add default code locations

   -- TODO: interrupts?
   -- 00:0150 - Entrypoint
   add_jump_call_location(rom, 0x00, 0x0150)

   return rom
end

function add_jump_call_location(
      rom, target_bank_num, target_address, source_bank_num, source_address)
   local bank_jump_call_locations = rom.jump_call_locations[target_bank_num]
   if bank_jump_call_locations[target_address] then
      return
   end

   local source = { source_bank_num, source_address }
   bank_jump_call_locations[target_address] = source
   rom.unparsed_jump_call_locations[target_bank_num][target_address] = source
end

local function read_rom_bank(rom, file)
   local symbols = rom.symbols
   local bank_num = rom.nbanks

   local rom_symbols = symbols.rom_banks
   local wram_symbols = symbols.wram_banks

   -- Read bank
   local bank = create_bank(bank_num, symbols, options)
   read_bank(bank, file)
   if bank.size == 0 then
      return
   end

   -- Add bank
   rom.banks[bank_num] = bank
   rom.nbanks = bank_num + 1

   -- Initialize metadata (bank 0 already initialized)
   if bank_num ~= 0x00 then
      rom.jump_call_locations[bank_num] = {}
      rom.unparsed_jump_call_locations[bank_num] = {}
      rom.context[bank_num] = {}
   end

   -- Initialize symbols
   if not rom_symbols[bank_num] then
      rom_symbols[bank_num] = create_rom_symbols()
   end
   if not wram_symbols[bank_num] then
      wram_symbols[bank_num] = create_ram_symbols()
   end

   return bank
end

local function read_rom_banks(rom, file)
   while read_rom_bank(rom, file) do
      --
   end
end

-- TODO: handle code end/data as new context
local function parse_code_regions(rom, bank_num)
   local bank = rom.banks[bank_num]
   local bank_context = rom.context[bank_num]

   local instructions = bank.instructions
   local data = bank.data

   for region in get_region_symbols(rom.symbols, bank_num) do
      if region.region_type == "code" then
         local address = region.address
         local remaining = region.size

         -- Don't parse regions that have already been parsed
         if not bank_context[address] then
            bank_context[address] = {}

            while remaining > 0 do
               local index = address % 0x4000

               -- Parse instruction
               local instruction = parse_next_instruction(data, index, remaining)

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
                     instruction_handler(rom, bank_num, address, instruction)
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

local function parse_jump_call_location(rom, bank_num, address)
   local regions = rom.symbols.rom_banks[bank_num].regions
   local bank = rom.banks[bank_num]

   local instructions = bank.instructions
   local data = bank.data

   rom.context[bank_num][address] = {}

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
      local instruction = parse_next_instruction(data, index)
      if not instruction then
         return
      end

      -- Record instruction
      instructions[address] = instruction

      -- Run instruction handler if available
      local instruction_handler = instruction_handlers[instruction.instruc]
      if instruction_handler then
         instruction_handler(rom, bank_num, address, instruction)
      end

      -- End parsing if instruction ends code
      if instruction.code_end then
         return
      end

      -- Iterate address
      address = address + (instruction.size or 1)
   end
end

local function parse_jump_call_locations(rom)
   local unparsed_jump_call_locations = rom.unparsed_jump_call_locations

   -- Parse call/jump locations
   local has_new_code_locations = true
   while has_new_code_locations do
      has_new_code_locations = false

      for bank_num, bank_jump_call_locations in pairs(unparsed_jump_call_locations) do
         -- Clear call/jump locations for next loop
         unparsed_jump_call_locations[bank_num] = {}

         for address in pairs(bank_jump_call_locations) do
            parse_jump_call_location(rom, bank_num, address)
            has_new_code_locations = true
         end
      end
   end
end

local function read_rom(rom, file)
   read_rom_banks(rom, file)

   for bank_num = 0, rom.nbanks - 1 do
      parse_code_regions(rom, bank_num)
   end

   parse_jump_call_locations(rom)
end

return {
   create_bank = create_bank,
   create_rom = create_rom,
   read_rom = read_rom
}
