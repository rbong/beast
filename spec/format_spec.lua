local beast = require("beast")

local Bank = beast.rom.Bank
local Formatter = beast.format.Formatter

describe("format", function()
    it("formats bank 0 header", function()
        local formatter = Formatter:new()
        assert.are.same('SECTION "ROM Bank $000", ROM0[$0000]', formatter:format_bank_header(0))
    end)

    it("formats bank 1 header", function()
        local formatter = Formatter:new()
        assert.are.same('SECTION "ROM Bank $001", ROMX[$4000], BANK[$001]', formatter:format_bank_header(1))
    end)

    it("formats bank 2 header", function()
        local formatter = Formatter:new()
        assert.are.same('SECTION "ROM Bank $002", ROMX[$4000], BANK[$002]', formatter:format_bank_header(2))
    end)

    it("formats basic instruction", function()
        local formatter = Formatter:new()
        assert.are.same("inc a", formatter:format_instruction(Bank:new(), {}, { instruc = "inc a" }, 0x0000))
    end)

    it("formats data", function()
        local formatter = Formatter:new()
        assert.are.same({ 1, "db $cb" }, {
            formatter:format_data(string.char(0xcb), 0),
        })
    end)

    it("formats byte instruction", function()
        local formatter = Formatter:new()
        assert.are.same(
            "ld a, $bf",
            formatter:format_instruction(Bank:new(), {}, { instruc = "ld a, n8", data = 0xbf }, 0x0000)
        )
    end)

    it("formats octet instruction", function()
        local formatter = Formatter:new()
        assert.are.same(
            "ld a, [$beef]",
            formatter:format_instruction(Bank:new(), {}, { instruc = "ld a, [n16]", data = 0xbeef }, 0x0000)
        )
    end)

    it("formats positive signed instruction", function()
        local formatter = Formatter:new()
        assert.are.same(
            "add sp, 1",
            formatter:format_instruction(Bank:new(), {}, { instruc = "add sp, e8", data = 1 }, 0x0000)
        )
    end)

    it("formats negative signed instruction", function()
        local formatter = Formatter:new()
        assert.are.same(
            "add sp, -1",
            formatter:format_instruction(Bank:new(), {}, { instruc = "add sp, e8", data = -1 }, 0x0000)
        )
    end)
end)
