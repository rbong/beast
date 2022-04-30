-- TODO: add support for all instructions

local function create_byte_op_instruction_formatter(format)
	 return function (data)
			return string.format(format, string.byte(data))
	 end
end

local function create_octet_op_instruction_formatter(format)
	 return function (data)
			return string.format(format, string.byte(data[2]), string.byte(data[1]))
	 end
end

local function create_signed_op_instruction_formatter(format)
	 return function (data)
			local value = string.byte(data)
			return string.format(format, (value >= 0x80) and (value - 256) or value)
	 end
end

local instruction_formatters = {
   -- "ld" Instructions --

   ["ld a, n8"] = create_byte_op_instruction_formatter("ld a, $%02x"),
   ["ld b, n8"] = create_byte_op_instruction_formatter("ld b, $%02x"),
   ["ld c, n8"] = create_byte_op_instruction_formatter("ld c, $%02x"),
   ["ld d, n8"] = create_byte_op_instruction_formatter("ld d, $%02x"),
   ["ld e, n8"] = create_byte_op_instruction_formatter("ld e, $%02x"),
   ["ld h, n8"] = create_byte_op_instruction_formatter("ld h, $%02x"),
   ["ld l, n8"] = create_byte_op_instruction_formatter("ld l, $%02x"),

   ["ld a, [n16]"] = create_octet_op_instruction_formatter("ld a, [$%02x%02x]"),
   ["ld [n16], a"] = create_octet_op_instruction_formatter("ld [$%02x%02x], a"),

   ["ldio a, [$ff00+n8]"] = create_byte_op_instruction_formatter("ldio a, [$ff00+$%02x]"),
   ["ldio [$ff00+n8], a"] = create_byte_op_instruction_formatter("ldio [$ff00+$%02x], a"),

   ["ld [hl], n8"] = create_byte_op_instruction_formatter("ld [hl], $%02x"),

   ["ld hl, n16"] = create_octet_op_instruction_formatter("ld hl, $%02x%02x"),
   ["ld bc, n16"] = create_octet_op_instruction_formatter("ld bc, $%02x%02x"),
   ["ld de, n16"] = create_octet_op_instruction_formatter("ld de, $%02x%02x"),

   -- Arithmetic Instructions --

   ["add a, n8"] = create_byte_op_instruction_formatter("add a, $%02x"),
   ["adc a, n8"] = create_byte_op_instruction_formatter("adc a, $%02x"),
   ["sub a, n8"] = create_byte_op_instruction_formatter("sub a, $%02x"),
   ["sbc a, n8"] = create_byte_op_instruction_formatter("sbc a, $%02x"),
   ["and a, n8"] = create_byte_op_instruction_formatter("and a, $%02x"),

   -- Logical Instructions --

   ["xor a, n8"] = create_byte_op_instruction_formatter("xor a, $%02x"),
   ["or a, n8"] = create_byte_op_instruction_formatter("or a, $%02x"),
   ["cp a, n8"] = create_byte_op_instruction_formatter("cp a, $%02x"),

   -- Stack Instructions --

   ["add sp, e8"] = create_signed_op_instruction_formatter("add sp, %d"),
   ["ld hl, sp+e8"] = create_signed_op_instruction_formatter("ld hl, sp%+d"),

   ["ld sp, n16"] = create_octet_op_instruction_formatter("ld sp, $%02x%02x"),
   ["ld [n16], sp"] = create_octet_op_instruction_formatter("ld [$%02x%02x], sp"),

   -- Jump/Call Instructions --

   ["call n16"] = create_octet_op_instruction_formatter("call $%02x%02x"),
   ["call c, n16"] = create_octet_op_instruction_formatter("call c, $%02x%02x"),
   ["call z, n16"] = create_octet_op_instruction_formatter("call z, $%02x%02x"),
   ["call nc, n16"] = create_octet_op_instruction_formatter("call nc, $%02x%02x"),
   ["call nz, n16"] = create_octet_op_instruction_formatter("call nz, $%02x%02x"),

	 -- TODO: use labels for these instructions
   ["jr e8"] = create_signed_op_instruction_formatter("jr @%+d+2"),
   ["jr c, e8"] = create_signed_op_instruction_formatter("jr c, @%+d+2"),
   ["jr z, e8"] = create_signed_op_instruction_formatter("jr z, @%+d+2"),
   ["jr nc, e8"] = create_signed_op_instruction_formatter("jr nc, @%+d+2"),
   ["jr nz, e8"] = create_signed_op_instruction_formatter("jr nz, @%+d+2"),

   ["jp n16"] = create_octet_op_instruction_formatter("jp $%02x%02x"),
   ["jp c, n16"] = create_octet_op_instruction_formatter("jp c, $%02x%02x"),
   ["jp z, n16"] = create_octet_op_instruction_formatter("jp z, $%02x%02x"),
   ["jp nc, n16"] = create_octet_op_instruction_formatter("jp nc, $%02x%02x"),
   ["jp nz, n16"] = create_octet_op_instruction_formatter("jp nz, $%02x%02x"),
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
			local instruction_formatter = instruction_formatters[instruction_type]

			-- Format complex instruction
			if instruction_formatter then
				 return instruction_formatter(instruction.data)
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
