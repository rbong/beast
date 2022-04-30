local beast = require("beast")

local create_symbols = beast.symbol.create_symbols
local read_symbols = beast.symbol.read_symbols

describe("symbols", function()
   it("handles non-definitions")

   describe("invalid targets", function()
      it("handles unsupported VRAM target")

      it("handles unsupported ECHO RAM target")

      it("handles unsupported ECHO RAM target")

      it("handles unsupported IO register target")

      it("handles unsupported IE target")
   end)

   describe("ROM", function()
      it("handles valid definitions", function()
         local sym = create_symbols()
         read_symbols(sym, io.open("./spec/fixtures/rom_valid.sym"))

         assert.are.same(sym.rom_banks[0].comments.definitions, {
               [0x0000] = { "Bank 0 comment body" }
            })
         assert.are.same(sym.rom_banks[0].labels.definitions, {
               [0x0100] = { "bank_0_label_value" },
               [0x0200] = { ".bank_0_local_label_value" }
            })
         assert.are.same(sym.rom_banks[0].regions.definitions, {
               [0x0300] = { region_type = "code", size = 4 },
               [0x0400] = { region_type = "data", size = 4 },
               [0x0500] = { region_type = "text", size = 4 }
            })
         assert.are.same(sym.rom_banks[0].replacements.definitions, {
               [0x0600] = { region_type = "replace", size = 4, value = "Bank 0 replacement body" }
            })
         assert.are.same(sym.rom_banks[0].operands.definitions, {
               [0x0700] = { left_op = "Bank 0 left operand" },
               [0x0800] = { left_op = nil, right_op = "Bank 0 right operand" }
            })

         assert.are.same(sym.rom_banks[1].comments.definitions, {
               [0x4000] = { "Bank 1 comment body" }
            })
         assert.are.same(sym.rom_banks[1].labels.definitions, {
               [0x4100] = { "bank_1_label_value" },
               [0x4200] = { ".bank_1_local_label_value" }
            })
         assert.are.same(sym.rom_banks[1].regions.definitions, {
               [0x4300] = { region_type = "code", size = 4 },
               [0x4400] = { region_type = "data", size = 4 },
               [0x4500] = { region_type = "text", size = 4 }
            })
         assert.are.same(sym.rom_banks[1].replacements.definitions, {
               [0x4600] = { region_type = "replace", size = 4, value = "Bank 1 replacement body" }
            })
         assert.are.same(sym.rom_banks[1].operands.definitions, {
               [0x4700] = { left_op = "Bank 1 left operand" },
               [0x4800] = { left_op = nil, right_op = "Bank 1 right operand" }
            })
      end)

      it("handles invalid bank 0 target")

      it("handles invalid high bank target")
   end)

   describe("SRAM", function()
      it("handles valid definitions")
   end)

   describe("WRAM", function()
      it("handles valid definitions", function()
         local sym = create_symbols()
         read_symbols(sym, io.open("./spec/fixtures/wram_valid.sym"))

         assert.are.same(sym.wram_banks[0].comments.definitions, {
               [0xc000] = { "Bank 0 comment body" }
            })
         assert.are.same(sym.wram_banks[0].labels.definitions, {
               [0xc100] = { "bank_0_label_value" }
            })

         assert.are.same(sym.wram_banks[1].comments.definitions, {
               [0xd000] = { "Bank 1 comment body" }
            })
         assert.are.same(sym.wram_banks[1].labels.definitions, {
               [0xd100] = { "bank_1_label_value" }
            })
      end)

      it("handles invalid bank 0 target")
   end)

   describe("HRAM", function()
      it("handles valid definitions")

      it("handles invalid banked target")
   end)
end)
