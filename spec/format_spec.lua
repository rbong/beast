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

   it("formats byte instruction", function ()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { { instruc = "ld a, n8", data = string.char(0xbf) } },
               1)
         },
         { 1, "ld a, $bf" })
   end)

   it("formats octet instruction", function ()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { { instruc = "ld a, [n16]", data = { string.char(0xef), string.char(0xbe) } } },
               1)
         },
         { 1, "ld a, [$beef]" })
   end)

   it("formats positive signed instruction", function ()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { { instruc = "add sp, e8", data = string.char(1) } },
               1)
         },
         { 1, "add sp, 1" })
   end)

   it("formats negative signed instruction", function ()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { { instruc = "add sp, e8", data = string.char(0xff) } },
               1)
         },
         { 1, "add sp, -1" })
   end)

   it("formats positive signed instruction with sign", function ()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { { instruc = "ld hl, sp+e8", data = string.char(1) } },
               1)
         },
         { 1, "ld hl, sp+1" })
   end)

   it("formats negative signed instruction with sign", function ()
      local formatter = format.create_formatter()
      assert.are.same(
         {
            format.format_instructions(
               formatter,
               { { instruc = "ld hl, sp+e8", data = string.char(0xff) } },
               1)
         },
         { 1, "ld hl, sp-1" })
   end)
end)
