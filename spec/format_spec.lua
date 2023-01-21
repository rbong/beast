local beast = require("beast")

local Formatter = beast.format.Formatter
local Options = beast.cli.Options
local Rom = beast.rom.Rom
local Bank = beast.rom.Bank
local Symbols = beast.symbol.Symbols

describe("Formatter", function()
    it("formats main file name", function()
        local formatter = Formatter:new(Options:new())
        assert.are.same("main.asm", formatter:get_main_file_name())
    end)

    it("formats main file path", function()
        local formatter = Formatter:new(Options:new())
        assert.are.same("base/main.asm", formatter:get_main_file_path("base"))
    end)

    it("formats memory file name", function()
        local formatter = Formatter:new(Options:new())
        assert.are.same("memory.asm", formatter:get_memory_file_name())
    end)

    it("formats memory file path", function()
        local formatter = Formatter:new(Options:new())
        assert.are.same("base/memory.asm", formatter:get_memory_file_path("base"))
    end)

    it("gets include files", function()
        local options = Options:new()
        options.include = { "foo/path_1.inc", "foo/bar/path_2.inc", "./foo/path_3.inc" }
        local formatter = Formatter:new(options)

        local includes = {}
        for source_path, file_name, path in formatter:get_include_files("base") do
            table.insert(includes, { source_path, file_name, path })
        end

        assert.are.same({
            { "foo/path_1.inc", "path_1.inc", "base/path_1.inc" },
            { "foo/bar/path_2.inc", "path_2.inc", "base/path_2.inc" },
            { "./foo/path_3.inc", "path_3.inc", "base/path_3.inc" },
        }, includes)
    end)

    it("formats bank header", function()
        local formatter = Formatter:new(Options:new())
        assert.are.same('SECTION "ROM Bank $000", ROM0[$0000]\n\n', formatter:format_bank_header(0))
        assert.are.same('SECTION "ROM Bank $001", ROMX[$4000], BANK[$001]\n\n', formatter:format_bank_header(1))
        assert.are.same('SECTION "ROM Bank $002", ROMX[$4000], BANK[$002]\n\n', formatter:format_bank_header(2))
    end)

    it("formats SRAM section header", function()
        local formatter = Formatter:new(Options:new())
        assert.are.same(
            'SECTION "SRAM_00_beef", SRAM[$beef], BANK[$00]\n',
            formatter:format_sram_section_header(0x00, 0xbeef)
        )
        assert.are.same(
            'SECTION "SRAM_01_beef", SRAM[$beef], BANK[$01]\n',
            formatter:format_sram_section_header(0x01, 0xbeef)
        )
    end)

    it("formats WRAM section header", function()
        local formatter = Formatter:new(Options:new())
        assert.are.same('SECTION "WRAM_00_beef", WRAM0[$beef]\n', formatter:format_wram_section_header(0x00, 0xbeef))
        assert.are.same(
            'SECTION "WRAM_01_beef", WRAMX[$beef], BANK[$01]\n',
            formatter:format_wram_section_header(0x01, 0xbeef)
        )
        assert.are.same(
            'SECTION "WRAM_02_beef", WRAMX[$beef], BANK[$02]\n',
            formatter:format_wram_section_header(0x02, 0xbeef)
        )
    end)

    it("formats HRAM section header", function()
        local formatter = Formatter:new(Options:new())
        assert.are.same('SECTION "HRAM_beef", HRAM[$beef]\n', formatter:format_hram_section_header(0xbeef))
    end)

    it("formats labels", function()
        local formatter = Formatter:new(Options:new())
        assert.are.same("my_label:\n", formatter:format_label("my_label"))
        assert.are.same(".my_label:\n", formatter:format_label(".my_label"))
    end)

    it("formats comments", function()
        local formatter = Formatter:new(Options:new())
        assert.are.same("; My comment\n", formatter:format_comment("My comment"))
        assert.are.same(";\n", formatter:format_comment(""))
    end)

    it("formats replacements", function()
        local formatter = Formatter:new(Options:new())
        assert.are.same("    MY_MACRO\n", formatter:format_replacement("MY_MACRO"))
        assert.are.same("\n", formatter:format_replacement(""))
    end)

    it("formats include statement", function()
        local formatter = Formatter:new(Options:new())
        assert.are.same('INCLUDE "my_file.asm"\n', formatter:format_include_statement("my_file.asm"))
    end)

    it("formats incbin statement", function()
        local formatter = Formatter:new(Options:new())
        assert.are.same('    INCBIN "my_file.data"', formatter:format_incbin_statement("my_file.data"))
    end)

    it("formats memory placeholder", function()
        local formatter = Formatter:new(Options:new())
        assert.are.same("    ds 1\n", formatter:format_memory_placeholder())
    end)

    it("formats ROM labels", function()
        local options = Options:new()
        local rom = Rom:new(options)
        local symbols = Symbols:new(options)
        local formatter = Formatter:new(options)

        rom.nbanks = 2

        rom:init_rom_bank_metadata(0x01)

        -- Bank 0 relative jump label
        rom.relative_jump_locations[0x00][0x0000] = true
        -- This relative jump label should be overwritten below
        rom.relative_jump_locations[0x00][0x0010] = true
        -- Bank 1 relative jump label
        rom.relative_jump_locations[0x01][0x4000] = true

        -- Bank 0 jump labels
        rom.jump_locations[0x00][0x0010] = true
        -- This jump label should be overwritten below
        rom.jump_locations[0x00][0x0020] = true
        -- Bank 1 jump label
        rom.jump_locations[0x01][0x4010] = true

        -- Bank 0 call label
        rom.call_locations[0x00][0x0020] = true
        -- This call label should be overwritten below
        rom.call_locations[0x00][0x0030] = true
        -- Bank 1 call label
        rom.call_locations[0x01][0x4020] = true

        -- Bank 0 RST call label
        rom.rst_call_locations[0x0030] = true
        -- This RST call label should be overwritten below
        rom.rst_call_locations[0x0040] = true

        -- Bank 0 manual labels
        symbols:add_label_symbol(0x00, 0x0040, "custom_foo_bank0")
        symbols:add_label_symbol(0x00, 0x0040, "custom_bar_bank0")
        -- Bank 1 manual labels
        symbols:add_label_symbol(0x01, 0x4040, "custom_foo_bank1")
        symbols:add_label_symbol(0x01, 0x4040, "custom_bar_bank1")

        assert.are.same({
            [0x00] = {
                [0x0000] = { "jr_00_0000" },
                [0x0010] = { "jump_00_0010" },
                [0x0020] = { "call_00_0020" },
                [0x0030] = { "rst_30" },
                [0x0040] = { "custom_foo_bank0", "custom_bar_bank0" },
            },
            [0x01] = {
                [0x4000] = { "jr_01_4000" },
                [0x4010] = { "jp_01_4010" },
                [0x4020] = { "call_01_4020" },
                [0x4040] = { "custom_foo_bank1", "custom_bar_bank1" },
            },
        }, formatter:format_rom_labels(rom, symbols))
    end)

    describe("instructions", function()
        local options
        local rom
        local bank
        local instructions
        local symbols
        local bank_symbols
        local formatter
        local rom_labels

        before_each(function()
            options = Options:new()
            rom = Rom:new(options)
            bank = Bank:new(0x00, options)

            rom.nbanks = 1
            rom.banks[0x00] = bank

            instructions = bank.instructions
            symbols = Symbols:new(options)
            bank_symbols = symbols:get_init_rom_bank(0x00)
            formatter = Formatter:new(options)
            rom_labels = formatter:format_rom_labels(rom, symbols)
        end)

        local function format_instruction(bank_num, address)
            return formatter:format_instruction(rom, symbols, rom_labels, bank_num or 0x00, address or 0x0000)
        end

        it("formats basic instruction", function()
            instructions[0x0000] = { instruc = "inc a" }
            assert.are.same("    inc a", format_instruction())
        end)

        it("formats byte instruction", function()
            instructions[0x0000] = { instruc = "ld a, n8", data = 0xbf }
            assert.are.same("    ld a, $bf", format_instruction())
        end)

        it("formats byte instruction with op symbol", function()
            bank_symbols.operands[0x0000] = "my_operand"
            instructions[0x0000] = { instruc = "ld a, n8", data = 0xbf }
            assert.are.same("    ld a, my_operand", format_instruction())
        end)

        it("formats HRAM instruction", function()
            instructions[0x0000] = { instruc = "ldio a, [$ff00+n8]", data = 0x02 }
            assert.are.same("    ldio a, [$ff00+$02]", format_instruction())
        end)

        it("formats HRAM instruction with op symbol", function()
            bank_symbols.operands[0x0000] = "$ff00 + my_operand"
            instructions[0x0000] = { instruc = "ldio a, [$ff00+n8]", data = 0x02 }
            assert.are.same("    ldio a, [$ff00 + my_operand]", format_instruction())
        end)

        it("formats octet instruction", function()
            instructions[0x0000] = { instruc = "ld a, [n16]", data = 0xbeef }
            assert.are.same("    ld a, [$beef]", format_instruction())
        end)

        it("formats octet instruction with op symbol", function()
            bank_symbols.operands[0x0000] = "my_operand"
            instructions[0x0000] = { instruc = "ld a, [n16]", data = 0xbeef }
            assert.are.same("    ld a, [my_operand]", format_instruction())
        end)

        it("formats octet instruction with WRAM label", function()
            symbols:add_label_symbol(0x00, 0xce2b, "my_label")
            instructions[0x0000] = { instruc = "ld a, [n16]", data = 0xce2b }
            assert.are.same("    ld a, [my_label]", format_instruction())
        end)

        it("formats octet instruction with ROM label", function()
            rom_labels[0x00][0x2b4e] = { "my_label" }
            instructions[0x0000] = { instruc = "ld a, [n16]", data = 0x2b4e }
            assert.are.same("    ld a, [my_label]", format_instruction())
        end)

        it("formats positive signed instruction", function()
            instructions[0x0000] = { instruc = "add sp, e8", data = 1 }
            assert.are.same("    add sp, 1", format_instruction())
        end)

        it("formats signed with op symbol", function()
            bank_symbols.operands[0x0000] = "my_operand"
            instructions[0x0000] = { instruc = "add sp, e8", data = 1 }
            assert.are.same("    add sp, my_operand", format_instruction())
        end)

        it("formats negative signed instruction", function()
            instructions[0x0000] = { instruc = "add sp, e8", data = -1 }
            assert.are.same("    add sp, -1", format_instruction())
        end)

        it("formats relative signed instruction", function()
            instructions[0x0000] = { instruc = "jr e8", data = 2 }
            assert.are.same("    jr @+4", format_instruction())
        end)

        it("formats relative signed instruction with label", function()
            rom_labels[0x00][0x0004] = { ".my_label" }
            instructions[0x0000] = { instruc = "jr e8", data = 2 }
            assert.are.same("    jr .my_label", format_instruction())
        end)
    end)

    local function bytes_to_string(bytes)
        local str = ""
        for _, byte in pairs(bytes) do
            str = str .. string.char(byte)
        end
        return str
    end

    it("formats full data line", function()
        local rom =
            { banks = { [0x00] = { data = bytes_to_string({ 0xa1, 0xc4, 0xdf, 0x11, 0x40, 0xfe, 0x01, 0x91 }) } } }
        local formatter = Formatter:new(Options:new())
        assert.are.same(
            "    db $a1, $c4, $df, $11, $40, $fe, $01, $91",
            formatter:format_full_data_line(rom, 0x00, 0x0000)
        )
    end)

    it("formats partial data line", function()
        local rom =
            { banks = { [0x00] = { data = bytes_to_string({ 0xa1, 0xc4, 0xdf, 0x11, 0x40, 0xfe, 0x01, 0x91 }) } } }
        local formatter = Formatter:new(Options:new())
        assert.are.same("    db $a1, $c4, $df, $11", formatter:format_partial_data_line(rom, 0x00, 0x0000, 4))
    end)

    it("formats text", function()
        local rom = { banks = { [0x00] = { data = 'my "string"\ttest\n\0foo\\bar' } } }
        local formatter = Formatter:new(Options:new())
        assert.are.same(
            '    db "my \\"string\\"\\ttest\\n", $00, "foo\\\\bar"',
            formatter:format_text(rom, 0x00, 0x0000, 25)
        )
    end)
end)

describe("FileGenerator")
