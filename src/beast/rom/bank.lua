local symbol = require("beast/symbol")

local create_symbols = symbol.create_symbols
local get_rom_area_regions = symbol.get_rom_area_regions

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

local function parse_bank_code_regions(bank)
   -- TODO: detect new code locaions
   local code_locations = {}

   local regions = bank.symbols.rom_banks[bank.bank_num]
   if regions then
      for address, region in get_rom_area_regions(regions) do
         if region.region_type == "code" then
            local remaining = region.size

            while remaining > 0 do
               local instruction = parse_next_instruction(bank.data, address, remaining)

               if instruction then
                  local size = region.size
                  remaining = remaining - size
                  address = address + size
               else
                  remaining = remaining - 1
                  address = address + 1
               end
            end
         end
      end
   end

   return code_locations
end

local function parse_bank_code_location(bank, address, max)
   local instructions = bank.instructions
   local nread = 0

   max = max or bank.size

   while max > 0 do
      local instruction = parse_next_instruction(bank.data, address, max)

      -- TODO: return on data
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

      -- TODO: return on code end
      -- if instruction.code_end then
      --    return nread
      -- end
   end

   return nread
end

return {
   create_bank = create_bank,
   read_bank = read_bank,
   parse_bank_code_regions = parse_bank_code_regions,
   parse_bank_code_location = parse_bank_code_location
}
