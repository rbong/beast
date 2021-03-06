local beast = require("beast")

local format = beast.format
local create_bank = beast.rom.create_bank

describe("format", function()
    it("formats bank 0 header", function()
        local formatter = format.create_formatter()
        assert.are.same('SECTION "ROM Bank $000", ROM0[$0000]', format.format_bank_header(formatter, 0))
    end)

    it("formats bank 1 header", function()
        local formatter = format.create_formatter()
        assert.are.same('SECTION "ROM Bank $001", ROMX[$4000], BANK[$001]', format.format_bank_header(formatter, 1))
    end)

    it("formats bank 2 header", function()
        local formatter = format.create_formatter()
        assert.are.same('SECTION "ROM Bank $002", ROMX[$4000], BANK[$002]', format.format_bank_header(formatter, 2))
    end)

    it("formats basic instruction", function()
        local formatter = format.create_formatter()
        assert.are.same("inc a", format.format_instruction(formatter, create_bank(), {}, { instruc = "inc a" }, 0x0000))
    end)

    it("formats data", function()
        local formatter = format.create_formatter()
        assert.are.same({ 1, "db $cb" }, {
            format.format_data(formatter, string.char(0xcb), 0),
        })
    end)

    it("formats byte instruction", function()
        local formatter = format.create_formatter()
        assert.are.same(
            "ld a, $bf",
            format.format_instruction(formatter, create_bank(), {}, { instruc = "ld a, n8", data = 0xbf }, 0x0000)
        )
    end)

    it("formats octet instruction", function()
        local formatter = format.create_formatter()
        assert.are.same(
            "ld a, [$beef]",
            format.format_instruction(formatter, create_bank(), {}, { instruc = "ld a, [n16]", data = 0xbeef }, 0x0000)
        )
    end)

    it("formats positive signed instruction", function()
        local formatter = format.create_formatter()
        assert.are.same(
            "add sp, 1",
            format.format_instruction(formatter, create_bank(), {}, { instruc = "add sp, e8", data = 1 }, 0x0000)
        )
    end)

    it("formats negative signed instruction", function()
        local formatter = format.create_formatter()
        assert.are.same(
            "add sp, -1",
            format.format_instruction(formatter, create_bank(), {}, { instruc = "add sp, e8", data = -1 }, 0x0000)
        )
    end)
end)
