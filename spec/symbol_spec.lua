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

            assert.are.same({
                [0x0000] = { "Bank 0 comment body" },
            }, sym.rom_banks[0].comments)
            assert.are.same({
                [0x0100] = { "bank_0_label_value" },
                [0x0200] = { ".bank_0_local_label_value" },
            }, sym.rom_banks[0].labels)
            assert.are.same({
                [0x0300] = { region_type = "code", address = 0x0300, size = 4 },
                [0x0400] = { region_type = "data", address = 0x0400, size = 4 },
                [0x0500] = { region_type = "text", address = 0x0500, size = 4 },
            }, sym.rom_banks[0].regions)
            assert.are.same({
                [0x0600] = { size = 4, body = "Bank 0 replacement body" },
            }, sym.rom_banks[0].replacements)
            assert.are.same({
                [0x0700] = "Bank 0 operand",
            }, sym.rom_banks[0].operands)

            assert.are.same({
                [0x4000] = { "Bank 1 comment body" },
            }, sym.rom_banks[1].comments)
            assert.are.same({
                [0x4100] = { "bank_1_label_value" },
                [0x4200] = { ".bank_1_local_label_value" },
            }, sym.rom_banks[1].labels)
            assert.are.same({
                [0x4300] = { region_type = "code", address = 0x4300, size = 4 },
                [0x4400] = { region_type = "data", address = 0x4400, size = 4 },
                [0x4500] = { region_type = "text", address = 0x4500, size = 4 },
            }, sym.rom_banks[1].regions)
            assert.are.same({
                [0x4600] = { size = 4, body = "Bank 1 replacement body" },
            }, sym.rom_banks[1].replacements)
            assert.are.same({
                [0x4700] = "Bank 1 operand",
            }, sym.rom_banks[1].operands)
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

            assert.are.same({
                [0xc000] = { "Bank 0 comment body" },
            }, sym.wram_banks[0].comments)
            assert.are.same({
                [0xc100] = { "bank_0_label_value" },
            }, sym.wram_banks[0].labels)

            assert.are.same({
                [0xd000] = { "Bank 1 comment body" },
            }, sym.wram_banks[1].comments)
            assert.are.same({
                [0xd100] = { "bank_1_label_value" },
            }, sym.wram_banks[1].labels)
        end)

        it("handles invalid bank 0 target")
    end)

    describe("HRAM", function()
        it("handles valid definitions")

        it("handles invalid banked target")
    end)

    it("get_region_symbols")
end)
