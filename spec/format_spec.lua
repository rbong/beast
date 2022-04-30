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
         "SECTION \"ROM Bank $002\", ROMX[$4000], BANK[$002]")
   end)

   it("formats basic instruction", function()
      local formatter = format.create_formatter()
      assert.are.same(
         format.format_instruction(
            formatter,
            { instruc = "inc a" }),
         "inc a")
   end)

   it("formats data", function()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_data(
               formatter,
               string.char(0xcb),
               0)
         },
         { 1, "db $cb" })
   end)

   it("formats byte instruction", function ()
      local formatter = format.create_formatter()
      assert.are.same(
         format.format_instruction(
            formatter,
            { instruc = "ld a, n8", data = 0xbf }),
         "ld a, $bf")
   end)

   it("formats octet instruction", function ()
      local formatter = format.create_formatter()
      assert.are.same(
         format.format_instruction(
            formatter,
            { instruc = "ld a, [n16]", data = 0xbeef }),
         "ld a, [$beef]")
   end)

   it("formats positive signed instruction", function ()
      local formatter = format.create_formatter()
      assert.are.same(
         format.format_instruction(
            formatter,
            { instruc = "add sp, e8", data = 1 }),
         "add sp, 1")
   end)

   it("formats negative signed instruction", function ()
      local formatter = format.create_formatter()
      assert.are.same(
         format.format_instruction(
            formatter,
            { instruc = "add sp, e8", data = -1 }),
         "add sp, -1")
   end)
end)
