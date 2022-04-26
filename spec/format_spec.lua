local beast = require("beast")

-- TODO: flip all assert.are.same arguments

local format = beast.format
local create_instruction = beast.rom.create_instruction
local create_data = beast.rom.create_data

local op = beast.rom.operands

local create_processor_register_operand = beast.rom.create_processor_register_operand
local create_dynamic_byte_operand = beast.rom.create_dynamic_byte_operand
local create_dynamic_octet_operand = beast.rom.create_dynamic_octet_operand

describe("format", function()
   it("formats bank 0 header", function()
      local formatter = format.create_formatter()
      assert.are.same(
         format.format_bank_header(formatter, 0),
         "SECTION \"ROM Bank $000\", ROM0[$0000]")
   end)

   it("formats bank 1 header", function()
      local formatter = format.create_formatter()
      assert.are.same(
         format.format_bank_header(formatter, 1),
         "SECTION \"ROM Bank $001\", ROMX[$4000], BANK[$001]")
   end)

   it("formats bank 2 header", function()
      local formatter = format.create_formatter()
      assert.are.same(
         format.format_bank_header(formatter, 2),
         "SECTION \"ROM Bank $002\", ROMX[$8000], BANK[$002]")
   end)

   it("formats instruction with register operand", function()
      local formatter = format.create_formatter()
      assert.are.same(
         { format.format_instructions(formatter, { create_instruction("inc", op.a_register) }, 1) },
         { 1, "inc a" })
   end)

   it("formats instruction with SP register operand", function()
      local formatter = format.create_formatter()
      assert.are.same(
         { format.format_instructions(formatter, { create_instruction("dec", op.sp_register) }, 1) },
         { 1, "dec sp" })
   end)

   it("formats instruction with register set operand", function()
      local formatter = format.create_formatter()
      assert.are.same(
         { format.format_instructions(formatter, { create_instruction("inc", op.hl_register_set) }, 1) },
         { 1, "inc hl" })
   end)

   it("formats instruction with two register operands", function()
      local formatter = format.create_formatter()
      assert.are.same(
         { format.format_instructions(formatter, { create_instruction("ld", op.b_register, op.c_register) }, 1) },
         { 1, "ld b, c" })
   end)

   it("formats instruction with condition operand", function()
      local formatter = format.create_formatter()
      assert.are.same(
         { format.format_instructions(formatter, { create_instruction("ret", op.z_condition) }, 1) },
         { 1, "ret z" })
   end)

   it("formats instruction with vector operand", function()
      local formatter = format.create_formatter()
      assert.are.same(
         { format.format_instructions(formatter, { create_instruction("rst", op.vector_18h) }, 1) },
         { 1, "rst $18" })
   end)

   it("formats instructions with dynamic byte operand", function()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { create_instruction("ld", op.b_register, create_dynamic_byte_operand(0x0b), 2) },
               1)
         },
         { 1, "ld b, $0b" })
   end)

   it("formats instructions with dynamic octet operand", function()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { create_instruction("jp", create_dynamic_octet_operand(0x0eef), nil, 3) },
               1)
         },
         { 1, "jp $0eef" })
   end)

   it("formats data", function()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { create_data("db", { 0xcb }) },
               1)
         },
         { 1, "db $cb" })
   end)

   -- TODO: test some of the previously unsupported operands
end)
