local beast = require("beast")

-- TODO: flip all assert.are.same arguments

local format = beast.format

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
         {
            format.format_instructions(
               formatter,
               { { code = "inc", l_op = { is_register = true, value = "a", size = 1 }, size = 1 } },
               1)
         },
         { 1, "inc a" })
   end)

   it("formats instruction with SP register operand", function()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { { code = "dec", l_op = { is_register = true, value = "sp", size = 1 }, size = 1 } },
               1)
         },
         { 1, "dec sp" })
   end)

   it("formats instruction with register set operand", function()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { { code = "inc", l_op = { is_register = true, value = "hl", size = 2 }, size = 1 } },
               1)
         },
         { 1, "inc hl" })
   end)

   it("formats instruction with two register operands", function()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { { code = "ld", l_op = { is_register = true, value = "b", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 } },
               1)
         },
         { 1, "ld b, c" })
   end)

   it("formats instruction with condition operand", function()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { { code = "ret", l_op = { is_condition = true, value = "z", size = 1 }, size = 1 } },
               1)
         },
         { 1, "ret z" })
   end)

   it("formats instruction with vector operand", function()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { { code = "rst", l_op = { is_vector = true, value = 0x18, size = 1 }, size = 1 } },
               1)
         },
         { 1, "rst $18" })
   end)

   it("formats instructions with dynamic byte operand", function()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { { code = "ld", l_op = { is_register = true, value = "b", size = 1 }, r_op = { is_dynamic = true, value = 0x0b, size = 1 }, size = 2 } },
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
               { { code = "jp", l_op = { is_dynamic = true, value = 0x0eef, size = 2 }, size = 3 } },
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
               { { code = "db", data = { 0xcb }, is_data = true, size = 1 } },
               1)
         },
         { 1, "db $cb" })
   end)

   -- TODO: test some of the previously unsupported operands
end)
