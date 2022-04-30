-- TODO: add support for all instructions

local instruction_formats = {
   -- "ld" Instructions --

   ["ld a, n8"] = "ld a, $%02x",
   ["ld b, n8"] = "ld b, $%02x",
   ["ld c, n8"] = "ld c, $%02x",
   ["ld d, n8"] = "ld d, $%02x",
   ["ld e, n8"] = "ld e, $%02x",
   ["ld h, n8"] = "ld h, $%02x",
   ["ld l, n8"] = "ld l, $%02x",

   ["ld a, [n16]"] = "ld a, [$%04x]",
   ["ld [n16], a"] = "ld [$%04x], a",

   ["ldio a, [$ff00+n8]"] = "ldio a, [$ff00+$%02x]",
   ["ldio [$ff00+n8], a"] = "ldio [$ff00+$%02x], a",

   ["ld [hl], n8"] = "ld [hl], $%02x",

   ["ld hl, n16"] = "ld hl, $%04x",
   ["ld bc, n16"] = "ld bc, $%04x",
   ["ld de, n16"] = "ld de, $%04x",

   -- Arithmetic Instructions --

   ["add a, n8"] = "add a, $%02x",
   ["adc a, n8"] = "adc a, $%02x",
   ["sub a, n8"] = "sub a, $%02x",
   ["sbc a, n8"] = "sbc a, $%02x",
   ["and a, n8"] = "and a, $%02x",

   -- Logical Instructions --

   ["xor a, n8"] = "xor a, $%02x",
   ["or a, n8"] = "or a, $%02x",
   ["cp a, n8"] = "cp a, $%02x",

   -- Stack Instructions --

   ["add sp, e8"] = "add sp, %d",
   ["ld hl, sp+e8"] = "ld hl, sp%+d",

   ["ld sp, n16"] = "ld sp, $%04x",
   ["ld [n16], sp"] = "ld [$%04x], sp",

   -- Jump/Call Instructions --

   ["call n16"] = "call $%04x",
   ["call c, n16"] = "call c, $%04x",
   ["call z, n16"] = "call z, $%04x",
   ["call nc, n16"] = "call nc, $%04x",
   ["call nz, n16"] = "call nz, $%04x",

	 -- TODO: use labels for these instructions
   ["jr e8"] = "jr @%+d+2",
   ["jr c, e8"] = "jr c, @%+d+2",
   ["jr z, e8"] = "jr z, @%+d+2",
   ["jr nc, e8"] = "jr nc, @%+d+2",
   ["jr nz, e8"] = "jr nz, @%+d+2",

   ["jp n16"] = "jp $%04x",
   ["jp c, n16"] = "jp c, $%04x",
   ["jp z, n16"] = "jp z, $%04x",
   ["jp nc, n16"] = "jp nc, $%04x",
   ["jp nz, n16"] = "jp nz, $%04x",
}

local function create_formatter(options)
   return {
			options = options
	 }
end

local function format_bank_header(formatter, bank_num)
   if bank_num == 0 then
      return "SECTION \"ROM Bank $000\", ROM0[$0000]"
   end

   return string.format(
      "SECTION \"ROM Bank $%03x\", ROMX[$4000], BANK[$%03x]",
      bank_num,
      bank_num)
end

local function format_instruction(formatter, instruction)
   local instruction_type = instruction.instruc

   if instruction_type then
			local instruction_format = instruction_formats[instruction_type]

			-- Format complex instruction
			if instruction_format then
				 return string.format(instruction_format, instruction.data)
			end

      -- Format basic instruction
      return instruction_type
   end

   error(string.format("Unrecognized instruction: %s", instruction.instruc))
end

local function format_data(formatter, data, address)
   local index = address + 1
   return 1, string.format("db $%02x", string.byte(data:sub(index, index)))
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

      local size = bank.size
      local instructions = bank.instructions
      local data = bank.data

      local address = 0

      while address < size do
         local instruction = instructions[address]

         if instruction then
            file:write(format_instruction(formatter, instruction))
            address = address + (instruction.size or 1)
         else
            local data_size, formatted_data = format_data(formatter, data, address)
            file:write(formatted_data)
            address = address + data_size
         end

         file:write("\n")
      end

      file:close()
   end
end

return {
   create_formatter = create_formatter,
   format_bank_header = format_bank_header,
   format_instruction = format_instruction,
   format_data = format_data,
   create_asm = create_asm
}
