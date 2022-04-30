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

   it("formats basic instruction", function()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { { instruc = "inc a" } },
               1)
         },
         { 1, "inc a" })
   end)

   it("formats data", function()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { { data = { string.char(0xcb) }, size = 1 } },
               1)
         },
         { 1, "db $cb" })
   end)

   -- TODO: test some of the previously unsupported operands
end)
