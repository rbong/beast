local beast = require("beast")

local Symbols = beast.symbol.Symbols

describe("symbols", function()
    it("handles non-definitions", function()
        local sym = Symbols:new()
        sym:read_symbols(io.open("./spec/fixtures/non_definitions.sym"))
    end)

    describe("invalid targets", function()
        it("handles invalid bank", function()
            assert.has_error(function()
                Symbols:new():get_memory_area(-1, 0x0000)
            end, "Invalid bank target: -1")
        end)

        it("handles invalid address", function()
            assert.has_error(function()
                Symbols:new():get_memory_area(0x00, -1)
            end, "Invalid address target: -1")

            assert.has_error(function()
                Symbols:new():get_memory_area(0x00, 0x10000)
            end, "Invalid address target: 00:10000")

            assert.has_error(function()
                Symbols:new():get_memory_area(0x00, 0xfea0)
            end, "Invalid address target: 00:fea0")
        end)

        it("handles invalid bank 0 ROM target", function()
            assert.has_error(function()
                Symbols:new():get_memory_area(0x00, 0x4000)
            end, "Invalid ROM target: 00:4000")
        end)

        it("handles invalid high bank ROM target", function()
            assert.has_error(function()
                Symbols:new():get_memory_area(0x01, 0x3fff)
            end, "Invalid ROM target: 01:3fff")
        end)

        it("handles unsupported VRAM target", function()
            assert.has_error(function()
                Symbols:new():get_memory_area(0x01, 0x8000)
            end, "Unsupported target in VRAM: 01:8000")
        end)

        it("handles invalid WRAM target", function()
            assert.has_error(function()
                Symbols:new():get_memory_area(0x01, 0xc000)
            end, "Invalid WRAM target: 01:c000")
        end)

        it("handles unsupported ECHO RAM target", function()
            assert.has_error(function()
                Symbols:new():get_memory_area(0x00, 0xe000)
            end, "Unsupported target in ECHO RAM: 00:e000")
        end)

        it("handles unsupported OAM target", function()
            assert.has_error(function()
                Symbols:new():get_memory_area(0x00, 0xfe00)
            end, "Unsupported target in OAM: 00:fe00")
        end)

        it("handles unsupported IO register target", function()
            assert.has_error(function()
                Symbols:new():get_memory_area(0x00, 0xff00)
            end, "Unsupported target in IO registers: 00:ff00")
        end)

        it("handles invalid HRAM bank", function()
            assert.has_error(function()
                Symbols:new():get_memory_area(0x01, 0xff80)
            end, "Invalid HRAM target: 01:ff80")
        end)

        it("handles unsupported IE target", function()
            assert.has_error(function()
                Symbols:new():get_memory_area(0x00, 0xffff)
            end, "Unsupported target IE: 00:ffff")
        end)
    end)

    describe("ROM", function()
        it("handles valid definitions", function()
            local sym = Symbols:new()
            sym:read_symbols(io.open("./spec/fixtures/rom_valid.sym"))

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
    end)

    describe("SRAM", function()
        it("handles valid definitions")
    end)

    describe("WRAM", function()
        it("handles valid definitions", function()
            local sym = Symbols:new()
            sym:read_symbols(io.open("./spec/fixtures/wram_valid.sym"))

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
    end)

    describe("HRAM", function()
        it("handles valid definitions")
    end)

    it("get_region_symbols")
end)
