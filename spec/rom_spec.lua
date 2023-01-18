local beast = require("beast")

local Symbols = beast.symbol.Symbols
local Rom = beast.rom.Rom

describe("Rom", function()
    it("reads a bank", function()
        local rom = Rom:new()
        local sym = Symbols:new()
        rom:read_rom(sym, io.open("./spec/fixtures/ret.gb", "rb"))
        assert.truthy(rom.nbanks == 1)
    end)

    it("reads a bank byte", function()
        local rom = Rom:new()
        local sym = Symbols:new()
        rom:read_rom(sym, io.open("./spec/fixtures/ret.gb", "rb"))
        assert.truthy(rom.banks[0].size == 1)
    end)

    it("reads ret instruction", function()
        local rom = Rom:new()
        local sym = Symbols:new()

        sym:add_region_symbol(0, 0, "code", 1)
        rom:read_rom(sym, io.open("./spec/fixtures/ret.gb", "rb"))

        assert.are.same({
            [0x000] = { instruc = "ret", code_end = true },
        }, rom.banks[0].instructions)
    end)

    it("reads basic instructions", function()
        local rom = Rom:new()
        local sym = Symbols:new()

        sym:add_region_symbol(0, 0, "code", 0x4000)
        rom:read_rom(sym, io.open("./spec/fixtures/basic_instructions.gb", "rb"))

        assert.are.same({
            [0x0000] = { instruc = "nop" },
            [0x0001] = { instruc = "halt" },
            [0x0002] = { instruc = "di" },
            [0x0003] = { instruc = "ei" },
            [0x0004] = { instruc = "ld a, a" },
            [0x0005] = { instruc = "ld a, b" },
            [0x0006] = { instruc = "ld a, c" },
            [0x0007] = { instruc = "ld a, d" },
            [0x0008] = { instruc = "ld a, e" },
            [0x0009] = { instruc = "ld a, h" },
            [0x000a] = { instruc = "ld a, l" },
            [0x000b] = { instruc = "ld b, a" },
            [0x000c] = { instruc = "ld b, b" },
            [0x000d] = { instruc = "ld b, c" },
            [0x000e] = { instruc = "ld b, d" },
            [0x000f] = { instruc = "ld b, e" },
            [0x0010] = { instruc = "ld b, h" },
            [0x0011] = { instruc = "ld b, l" },
            [0x0012] = { instruc = "ld c, a" },
            [0x0013] = { instruc = "ld c, b" },
            [0x0014] = { instruc = "ld c, c" },
            [0x0015] = { instruc = "ld c, d" },
            [0x0016] = { instruc = "ld c, e" },
            [0x0017] = { instruc = "ld c, h" },
            [0x0018] = { instruc = "ld c, l" },
            [0x0019] = { instruc = "ld d, a" },
            [0x001a] = { instruc = "ld d, b" },
            [0x001b] = { instruc = "ld d, c" },
            [0x001c] = { instruc = "ld d, d" },
            [0x001d] = { instruc = "ld d, e" },
            [0x001e] = { instruc = "ld d, h" },
            [0x001f] = { instruc = "ld d, l" },
            [0x0020] = { instruc = "ld e, a" },
            [0x0021] = { instruc = "ld e, b" },
            [0x0022] = { instruc = "ld e, c" },
            [0x0023] = { instruc = "ld e, d" },
            [0x0024] = { instruc = "ld e, e" },
            [0x0025] = { instruc = "ld e, h" },
            [0x0026] = { instruc = "ld e, l" },
            [0x0027] = { instruc = "ld h, a" },
            [0x0028] = { instruc = "ld h, b" },
            [0x0029] = { instruc = "ld h, c" },
            [0x002a] = { instruc = "ld h, d" },
            [0x002b] = { instruc = "ld h, e" },
            [0x002c] = { instruc = "ld h, h" },
            [0x002d] = { instruc = "ld h, l" },
            [0x002e] = { instruc = "ld l, a" },
            [0x002f] = { instruc = "ld l, b" },
            [0x0030] = { instruc = "ld l, c" },
            [0x0031] = { instruc = "ld l, d" },
            [0x0032] = { instruc = "ld l, e" },
            [0x0033] = { instruc = "ld l, h" },
            [0x0034] = { instruc = "ld l, l" },
            [0x0035] = { instruc = "ld a, [hl]" },
            [0x0036] = { instruc = "ld b, [hl]" },
            [0x0037] = { instruc = "ld c, [hl]" },
            [0x0038] = { instruc = "ld d, [hl]" },
            [0x0039] = { instruc = "ld e, [hl]" },
            [0x003a] = { instruc = "ld h, [hl]" },
            [0x003b] = { instruc = "ld l, [hl]" },
            [0x003c] = { instruc = "ld [hl], a" },
            [0x003d] = { instruc = "ld [hl], b" },
            [0x003e] = { instruc = "ld [hl], c" },
            [0x003f] = { instruc = "ld [hl], d" },
            [0x0040] = { instruc = "ld [hl], e" },
            [0x0041] = { instruc = "ld [hl], h" },
            [0x0042] = { instruc = "ld [hl], l" },
            [0x0043] = { instruc = "ld a, [$ff00+c]" },
            [0x0044] = { instruc = "ld [$ff00+c], a" },
            [0x0045] = { instruc = "ld a, [hl+]" },
            [0x0046] = { instruc = "ld a, [hl-]" },
            [0x0047] = { instruc = "ld a, [bc]" },
            [0x0048] = { instruc = "ld a, [de]" },
            [0x0049] = { instruc = "ld [hl+], a" },
            [0x004a] = { instruc = "ld [hl-], a" },
            [0x004b] = { instruc = "ld [bc], a" },
            [0x004c] = { instruc = "ld [de], a" },
            [0x004d] = { instruc = "add a, a" },
            [0x004e] = { instruc = "add a, b" },
            [0x004f] = { instruc = "add a, c" },
            [0x0050] = { instruc = "add a, d" },
            [0x0051] = { instruc = "add a, e" },
            [0x0052] = { instruc = "add a, h" },
            [0x0053] = { instruc = "add a, l" },
            [0x0054] = { instruc = "add a, [hl]" },
            [0x0055] = { instruc = "adc a, a" },
            [0x0056] = { instruc = "adc a, b" },
            [0x0057] = { instruc = "adc a, c" },
            [0x0058] = { instruc = "adc a, d" },
            [0x0059] = { instruc = "adc a, e" },
            [0x005a] = { instruc = "adc a, h" },
            [0x005b] = { instruc = "adc a, l" },
            [0x005c] = { instruc = "adc a, [hl]" },
            [0x005d] = { instruc = "sub a, a" },
            [0x005e] = { instruc = "sub a, b" },
            [0x005f] = { instruc = "sub a, c" },
            [0x0060] = { instruc = "sub a, d" },
            [0x0061] = { instruc = "sub a, e" },
            [0x0062] = { instruc = "sub a, h" },
            [0x0063] = { instruc = "sub a, l" },
            [0x0064] = { instruc = "sub a, [hl]" },
            [0x0065] = { instruc = "sbc a, a" },
            [0x0066] = { instruc = "sbc a, b" },
            [0x0067] = { instruc = "sbc a, c" },
            [0x0068] = { instruc = "sbc a, d" },
            [0x0069] = { instruc = "sbc a, e" },
            [0x006a] = { instruc = "sbc a, h" },
            [0x006b] = { instruc = "sbc a, l" },
            [0x006c] = { instruc = "sbc a, [hl]" },
            [0x006d] = { instruc = "add hl, hl" },
            [0x006e] = { instruc = "add hl, bc" },
            [0x006f] = { instruc = "add hl, de" },
            [0x0070] = { instruc = "daa" },
            [0x0071] = { instruc = "scf" },
            [0x0072] = { instruc = "and a, a" },
            [0x0073] = { instruc = "and a, b" },
            [0x0074] = { instruc = "and a, c" },
            [0x0075] = { instruc = "and a, d" },
            [0x0076] = { instruc = "and a, e" },
            [0x0077] = { instruc = "and a, h" },
            [0x0078] = { instruc = "and a, l" },
            [0x0079] = { instruc = "and a, [hl]" },
            [0x007a] = { instruc = "xor a, a" },
            [0x007b] = { instruc = "xor a, b" },
            [0x007c] = { instruc = "xor a, c" },
            [0x007d] = { instruc = "xor a, d" },
            [0x007e] = { instruc = "xor a, e" },
            [0x007f] = { instruc = "xor a, h" },
            [0x0080] = { instruc = "xor a, l" },
            [0x0081] = { instruc = "xor a, [hl]" },
            [0x0082] = { instruc = "or a, a" },
            [0x0083] = { instruc = "or a, b" },
            [0x0084] = { instruc = "or a, c" },
            [0x0085] = { instruc = "or a, d" },
            [0x0086] = { instruc = "or a, e" },
            [0x0087] = { instruc = "or a, h" },
            [0x0088] = { instruc = "or a, l" },
            [0x0089] = { instruc = "or a, [hl]" },
            [0x008a] = { instruc = "cp a, a" },
            [0x008b] = { instruc = "cp a, b" },
            [0x008c] = { instruc = "cp a, c" },
            [0x008d] = { instruc = "cp a, d" },
            [0x008e] = { instruc = "cp a, e" },
            [0x008f] = { instruc = "cp a, h" },
            [0x0090] = { instruc = "cp a, l" },
            [0x0091] = { instruc = "cp a, [hl]" },
            [0x0092] = { instruc = "cpl" },
            [0x0093] = { instruc = "ccf" },
            [0x0094] = { instruc = "rlca" },
            [0x0095] = { instruc = "rla" },
            [0x0096] = { instruc = "rrca" },
            [0x0097] = { instruc = "rra" },
            [0x0098] = { instruc = "inc a" },
            [0x0099] = { instruc = "inc b" },
            [0x009a] = { instruc = "inc c" },
            [0x009b] = { instruc = "inc d" },
            [0x009c] = { instruc = "inc e" },
            [0x009d] = { instruc = "inc h" },
            [0x009e] = { instruc = "inc l" },
            [0x009f] = { instruc = "inc hl" },
            [0x00a0] = { instruc = "inc bc" },
            [0x00a1] = { instruc = "inc de" },
            [0x00a2] = { instruc = "inc [hl]" },
            [0x00a3] = { instruc = "dec a" },
            [0x00a4] = { instruc = "dec b" },
            [0x00a5] = { instruc = "dec c" },
            [0x00a6] = { instruc = "dec d" },
            [0x00a7] = { instruc = "dec e" },
            [0x00a8] = { instruc = "dec h" },
            [0x00a9] = { instruc = "dec l" },
            [0x00aa] = { instruc = "dec hl" },
            [0x00ab] = { instruc = "dec bc" },
            [0x00ac] = { instruc = "dec de" },
            [0x00ad] = { instruc = "dec [hl]" },
            [0x00ae] = { instruc = "push af" },
            [0x00af] = { instruc = "push bc" },
            [0x00b0] = { instruc = "push de" },
            [0x00b1] = { instruc = "push hl" },
            [0x00b2] = { instruc = "pop af" },
            [0x00b3] = { instruc = "pop bc" },
            [0x00b4] = { instruc = "pop de" },
            [0x00b5] = { instruc = "pop hl" },
            [0x00b6] = { instruc = "inc sp" },
            [0x00b7] = { instruc = "dec sp" },
            [0x00b8] = { instruc = "ld sp, hl" },
            [0x00b9] = { instruc = "add hl, sp" },
            [0x00ba] = { instruc = "jp hl" },
            [0x00bb] = { instruc = "rst $00" },
            [0x00bc] = { instruc = "rst $08" },
            [0x00bd] = { instruc = "rst $10" },
            [0x00be] = { instruc = "rst $18" },
            [0x00bf] = { instruc = "rst $20" },
            [0x00c0] = { instruc = "rst $28" },
            [0x00c1] = { instruc = "rst $30" },
            [0x00c2] = { instruc = "rst $38" },
            [0x00c3] = { instruc = "ret", code_end = true },
            [0x00c4] = { instruc = "reti", code_end = true },
            [0x00c5] = { instruc = "ret c" },
            [0x00c6] = { instruc = "ret z" },
            [0x00c7] = { instruc = "ret nc" },
            [0x00c8] = { instruc = "ret nz" },
        }, rom.banks[0].instructions)
    end)

    it("reads instructions with a dynamic byte operand", function()
        local rom = Rom:new()
        local sym = Symbols:new()

        sym:add_region_symbol(0, 0, "code", 0x4000)
        rom:read_rom(sym, io.open("./spec/fixtures/byte_op_instructions.gb", "rb"))

        assert.are.same({
            [0x0000] = { instruc = "ld a, n8", data = 0x00, size = 2 },
            [0x0002] = { instruc = "ld b, n8", data = 0x10, size = 2 },
            [0x0004] = { instruc = "ld c, n8", data = 0x20, size = 2 },
            [0x0006] = { instruc = "ld d, n8", data = 0x30, size = 2 },
            [0x0008] = { instruc = "ld e, n8", data = 0x40, size = 2 },
            [0x000a] = { instruc = "ld h, n8", data = 0x50, size = 2 },
            [0x000c] = { instruc = "ld l, n8", data = 0x60, size = 2 },
            [0x000e] = { instruc = "ldio a, [$ff00+n8]", data = 0x70, size = 2 },
            [0x0010] = { instruc = "ldio [$ff00+n8], a", data = 0x80, size = 2 },
            [0x0012] = { instruc = "ld [hl], n8", data = 0x90, size = 2 },
            [0x0014] = { instruc = "add a, n8", data = 0xa0, size = 2 },
            [0x0016] = { instruc = "adc a, n8", data = 0xb0, size = 2 },
            [0x0018] = { instruc = "sub a, n8", data = 0xc0, size = 2 },
            [0x001a] = { instruc = "sbc a, n8", data = 0xd0, size = 2 },
            [0x001c] = { instruc = "and a, n8", data = 0xe0, size = 2 },
            [0x001e] = { instruc = "xor a, n8", data = 0xf0, size = 2 },
            [0x0020] = { instruc = "or a, n8", data = 0x01, size = 2 },
            [0x0022] = { instruc = "cp a, n8", data = 0x11, size = 2 },
            [0x0024] = { instruc = "add sp, e8", data = 0x21, size = 2 },
            [0x0026] = { instruc = "ld hl, sp+e8", data = 0x31, size = 2 },
            [0x0028] = { instruc = "jr e8", data = -2, size = 2 },
            [0x002a] = { instruc = "jr c, e8", data = -4, size = 2 },
            [0x002c] = { instruc = "jr z, e8", data = -6, size = 2 },
            [0x002e] = { instruc = "jr nc, e8", data = -8, size = 2 },
            [0x0030] = { instruc = "jr nz, e8", data = -10, size = 2 },
        }, rom.banks[0].instructions)
    end)

    it("reads instructions with a dynamic octet operand", function()
        local rom = Rom:new()
        local sym = Symbols:new()

        sym:add_region_symbol(0, 0, "code", 0x4000)
        rom:read_rom(sym, io.open("./spec/fixtures/octet_op_instructions.gb", "rb"))

        assert.are.same({
            [0x0000] = { instruc = "ld a, [n16]", data = 0x0000, size = 3 },
            [0x0003] = { instruc = "ld [n16], a", data = 0x0100, size = 3 },
            [0x0006] = { instruc = "ld hl, n16", data = 0x0200, size = 3 },
            [0x0009] = { instruc = "ld bc, n16", data = 0x0300, size = 3 },
            [0x000c] = { instruc = "ld de, n16", data = 0x0400, size = 3 },
            [0x000f] = { instruc = "ld sp, n16", data = 0x0500, size = 3 },
            [0x0012] = { instruc = "ld [n16], sp", data = 0x0600, size = 3 },
            [0x0015] = { instruc = "call n16", data = 0x0700, size = 3 },
            [0x0018] = { instruc = "call c, n16", data = 0x0800, size = 3 },
            [0x001b] = { instruc = "call z, n16", data = 0x0900, size = 3 },
            [0x001e] = { instruc = "call nc, n16", data = 0x0a00, size = 3 },
            [0x0021] = { instruc = "call nz, n16", data = 0x0b00, size = 3 },
            [0x0024] = { instruc = "jp n16", data = 0x0c00, size = 3 },
            [0x0027] = { instruc = "jp c, n16", data = 0x0f00, size = 3 },
            [0x002a] = { instruc = "jp z, n16", data = 0x1000, size = 3 },
            [0x002d] = { instruc = "jp nc, n16", data = 0x1100, size = 3 },
            [0x0030] = { instruc = "jp nz, n16", data = 0x1200, size = 3 },
        }, rom.banks[0].instructions)
    end)

    it("reads extended instructions", function()
        local rom = Rom:new()
        local sym = Symbols:new()

        sym:add_region_symbol(0, 0, "code", 0x4000)
        rom:read_rom(sym, io.open("./spec/fixtures/extended_instructions.gb", "rb"))

        assert.are.same({
            [0x0000] = { instruc = "stop", size = 2 },
            [0x0002] = { instruc = "rlc a", size = 2 },
            [0x0004] = { instruc = "rlc b", size = 2 },
            [0x0006] = { instruc = "rlc c", size = 2 },
            [0x0008] = { instruc = "rlc d", size = 2 },
            [0x000a] = { instruc = "rlc e", size = 2 },
            [0x000c] = { instruc = "rlc h", size = 2 },
            [0x000e] = { instruc = "rlc l", size = 2 },
            [0x0010] = { instruc = "rlc [hl]", size = 2 },
            [0x0012] = { instruc = "rrc a", size = 2 },
            [0x0014] = { instruc = "rrc b", size = 2 },
            [0x0016] = { instruc = "rrc c", size = 2 },
            [0x0018] = { instruc = "rrc d", size = 2 },
            [0x001a] = { instruc = "rrc e", size = 2 },
            [0x001c] = { instruc = "rrc h", size = 2 },
            [0x001e] = { instruc = "rrc l", size = 2 },
            [0x0020] = { instruc = "rrc [hl]", size = 2 },
            [0x0022] = { instruc = "rl a", size = 2 },
            [0x0024] = { instruc = "rl b", size = 2 },
            [0x0026] = { instruc = "rl c", size = 2 },
            [0x0028] = { instruc = "rl d", size = 2 },
            [0x002a] = { instruc = "rl e", size = 2 },
            [0x002c] = { instruc = "rl h", size = 2 },
            [0x002e] = { instruc = "rl l", size = 2 },
            [0x0030] = { instruc = "rl [hl]", size = 2 },
            [0x0032] = { instruc = "rr a", size = 2 },
            [0x0034] = { instruc = "rr b", size = 2 },
            [0x0036] = { instruc = "rr c", size = 2 },
            [0x0038] = { instruc = "rr d", size = 2 },
            [0x003a] = { instruc = "rr e", size = 2 },
            [0x003c] = { instruc = "rr h", size = 2 },
            [0x003e] = { instruc = "rr l", size = 2 },
            [0x0040] = { instruc = "rr [hl]", size = 2 },
            [0x0042] = { instruc = "sla a", size = 2 },
            [0x0044] = { instruc = "sla b", size = 2 },
            [0x0046] = { instruc = "sla c", size = 2 },
            [0x0048] = { instruc = "sla d", size = 2 },
            [0x004a] = { instruc = "sla e", size = 2 },
            [0x004c] = { instruc = "sla h", size = 2 },
            [0x004e] = { instruc = "sla l", size = 2 },
            [0x0050] = { instruc = "sla [hl]", size = 2 },
            [0x0052] = { instruc = "sra a", size = 2 },
            [0x0054] = { instruc = "sra b", size = 2 },
            [0x0056] = { instruc = "sra c", size = 2 },
            [0x0058] = { instruc = "sra d", size = 2 },
            [0x005a] = { instruc = "sra e", size = 2 },
            [0x005c] = { instruc = "sra h", size = 2 },
            [0x005e] = { instruc = "sra l", size = 2 },
            [0x0060] = { instruc = "sra [hl]", size = 2 },
            [0x0062] = { instruc = "swap a", size = 2 },
            [0x0064] = { instruc = "swap b", size = 2 },
            [0x0066] = { instruc = "swap c", size = 2 },
            [0x0068] = { instruc = "swap d", size = 2 },
            [0x006a] = { instruc = "swap e", size = 2 },
            [0x006c] = { instruc = "swap h", size = 2 },
            [0x006e] = { instruc = "swap l", size = 2 },
            [0x0070] = { instruc = "swap [hl]", size = 2 },
            [0x0072] = { instruc = "srl a", size = 2 },
            [0x0074] = { instruc = "srl b", size = 2 },
            [0x0076] = { instruc = "srl c", size = 2 },
            [0x0078] = { instruc = "srl d", size = 2 },
            [0x007a] = { instruc = "srl e", size = 2 },
            [0x007c] = { instruc = "srl h", size = 2 },
            [0x007e] = { instruc = "srl l", size = 2 },
            [0x0080] = { instruc = "srl [hl]", size = 2 },
            [0x0082] = { instruc = "bit 0, a", size = 2 },
            [0x0084] = { instruc = "bit 0, b", size = 2 },
            [0x0086] = { instruc = "bit 0, c", size = 2 },
            [0x0088] = { instruc = "bit 0, d", size = 2 },
            [0x008a] = { instruc = "bit 0, e", size = 2 },
            [0x008c] = { instruc = "bit 0, h", size = 2 },
            [0x008e] = { instruc = "bit 0, l", size = 2 },
            [0x0090] = { instruc = "bit 0, [hl]", size = 2 },
            [0x0092] = { instruc = "bit 1, a", size = 2 },
            [0x0094] = { instruc = "bit 1, b", size = 2 },
            [0x0096] = { instruc = "bit 1, c", size = 2 },
            [0x0098] = { instruc = "bit 1, d", size = 2 },
            [0x009a] = { instruc = "bit 1, e", size = 2 },
            [0x009c] = { instruc = "bit 1, h", size = 2 },
            [0x009e] = { instruc = "bit 1, l", size = 2 },
            [0x00a0] = { instruc = "bit 1, [hl]", size = 2 },
            [0x00a2] = { instruc = "bit 2, a", size = 2 },
            [0x00a4] = { instruc = "bit 2, b", size = 2 },
            [0x00a6] = { instruc = "bit 2, c", size = 2 },
            [0x00a8] = { instruc = "bit 2, d", size = 2 },
            [0x00aa] = { instruc = "bit 2, e", size = 2 },
            [0x00ac] = { instruc = "bit 2, h", size = 2 },
            [0x00ae] = { instruc = "bit 2, l", size = 2 },
            [0x00b0] = { instruc = "bit 2, [hl]", size = 2 },
            [0x00b2] = { instruc = "bit 3, a", size = 2 },
            [0x00b4] = { instruc = "bit 3, b", size = 2 },
            [0x00b6] = { instruc = "bit 3, c", size = 2 },
            [0x00b8] = { instruc = "bit 3, d", size = 2 },
            [0x00ba] = { instruc = "bit 3, e", size = 2 },
            [0x00bc] = { instruc = "bit 3, h", size = 2 },
            [0x00be] = { instruc = "bit 3, l", size = 2 },
            [0x00c0] = { instruc = "bit 3, [hl]", size = 2 },
            [0x00c2] = { instruc = "bit 4, a", size = 2 },
            [0x00c4] = { instruc = "bit 4, b", size = 2 },
            [0x00c6] = { instruc = "bit 4, c", size = 2 },
            [0x00c8] = { instruc = "bit 4, d", size = 2 },
            [0x00ca] = { instruc = "bit 4, e", size = 2 },
            [0x00cc] = { instruc = "bit 4, h", size = 2 },
            [0x00ce] = { instruc = "bit 4, l", size = 2 },
            [0x00d0] = { instruc = "bit 4, [hl]", size = 2 },
            [0x00d2] = { instruc = "bit 5, a", size = 2 },
            [0x00d4] = { instruc = "bit 5, b", size = 2 },
            [0x00d6] = { instruc = "bit 5, c", size = 2 },
            [0x00d8] = { instruc = "bit 5, d", size = 2 },
            [0x00da] = { instruc = "bit 5, e", size = 2 },
            [0x00dc] = { instruc = "bit 5, h", size = 2 },
            [0x00de] = { instruc = "bit 5, l", size = 2 },
            [0x00e0] = { instruc = "bit 5, [hl]", size = 2 },
            [0x00e2] = { instruc = "bit 6, a", size = 2 },
            [0x00e4] = { instruc = "bit 6, b", size = 2 },
            [0x00e6] = { instruc = "bit 6, c", size = 2 },
            [0x00e8] = { instruc = "bit 6, d", size = 2 },
            [0x00ea] = { instruc = "bit 6, e", size = 2 },
            [0x00ec] = { instruc = "bit 6, h", size = 2 },
            [0x00ee] = { instruc = "bit 6, l", size = 2 },
            [0x00f0] = { instruc = "bit 6, [hl]", size = 2 },
            [0x00f2] = { instruc = "bit 7, a", size = 2 },
            [0x00f4] = { instruc = "bit 7, b", size = 2 },
            [0x00f6] = { instruc = "bit 7, c", size = 2 },
            [0x00f8] = { instruc = "bit 7, d", size = 2 },
            [0x00fa] = { instruc = "bit 7, e", size = 2 },
            [0x00fc] = { instruc = "bit 7, h", size = 2 },
            [0x00fe] = { instruc = "bit 7, l", size = 2 },
            [0x0100] = { instruc = "bit 7, [hl]", size = 2 },
            [0x0102] = { instruc = "res 0, a", size = 2 },
            [0x0104] = { instruc = "res 0, b", size = 2 },
            [0x0106] = { instruc = "res 0, c", size = 2 },
            [0x0108] = { instruc = "res 0, d", size = 2 },
            [0x010a] = { instruc = "res 0, e", size = 2 },
            [0x010c] = { instruc = "res 0, h", size = 2 },
            [0x010e] = { instruc = "res 0, l", size = 2 },
            [0x0110] = { instruc = "res 0, [hl]", size = 2 },
            [0x0112] = { instruc = "res 1, a", size = 2 },
            [0x0114] = { instruc = "res 1, b", size = 2 },
            [0x0116] = { instruc = "res 1, c", size = 2 },
            [0x0118] = { instruc = "res 1, d", size = 2 },
            [0x011a] = { instruc = "res 1, e", size = 2 },
            [0x011c] = { instruc = "res 1, h", size = 2 },
            [0x011e] = { instruc = "res 1, l", size = 2 },
            [0x0120] = { instruc = "res 1, [hl]", size = 2 },
            [0x0122] = { instruc = "res 2, a", size = 2 },
            [0x0124] = { instruc = "res 2, b", size = 2 },
            [0x0126] = { instruc = "res 2, c", size = 2 },
            [0x0128] = { instruc = "res 2, d", size = 2 },
            [0x012a] = { instruc = "res 2, e", size = 2 },
            [0x012c] = { instruc = "res 2, h", size = 2 },
            [0x012e] = { instruc = "res 2, l", size = 2 },
            [0x0130] = { instruc = "res 2, [hl]", size = 2 },
            [0x0132] = { instruc = "res 3, a", size = 2 },
            [0x0134] = { instruc = "res 3, b", size = 2 },
            [0x0136] = { instruc = "res 3, c", size = 2 },
            [0x0138] = { instruc = "res 3, d", size = 2 },
            [0x013a] = { instruc = "res 3, e", size = 2 },
            [0x013c] = { instruc = "res 3, h", size = 2 },
            [0x013e] = { instruc = "res 3, l", size = 2 },
            [0x0140] = { instruc = "res 3, [hl]", size = 2 },
            [0x0142] = { instruc = "res 4, a", size = 2 },
            [0x0144] = { instruc = "res 4, b", size = 2 },
            [0x0146] = { instruc = "res 4, c", size = 2 },
            [0x0148] = { instruc = "res 4, d", size = 2 },
            [0x014a] = { instruc = "res 4, e", size = 2 },
            [0x014c] = { instruc = "res 4, h", size = 2 },
            [0x014e] = { instruc = "res 4, l", size = 2 },
            [0x0150] = { instruc = "res 4, [hl]", size = 2 },
            [0x0152] = { instruc = "res 5, a", size = 2 },
            [0x0154] = { instruc = "res 5, b", size = 2 },
            [0x0156] = { instruc = "res 5, c", size = 2 },
            [0x0158] = { instruc = "res 5, d", size = 2 },
            [0x015a] = { instruc = "res 5, e", size = 2 },
            [0x015c] = { instruc = "res 5, h", size = 2 },
            [0x015e] = { instruc = "res 5, l", size = 2 },
            [0x0160] = { instruc = "res 5, [hl]", size = 2 },
            [0x0162] = { instruc = "res 6, a", size = 2 },
            [0x0164] = { instruc = "res 6, b", size = 2 },
            [0x0166] = { instruc = "res 6, c", size = 2 },
            [0x0168] = { instruc = "res 6, d", size = 2 },
            [0x016a] = { instruc = "res 6, e", size = 2 },
            [0x016c] = { instruc = "res 6, h", size = 2 },
            [0x016e] = { instruc = "res 6, l", size = 2 },
            [0x0170] = { instruc = "res 6, [hl]", size = 2 },
            [0x0172] = { instruc = "res 7, a", size = 2 },
            [0x0174] = { instruc = "res 7, b", size = 2 },
            [0x0176] = { instruc = "res 7, c", size = 2 },
            [0x0178] = { instruc = "res 7, d", size = 2 },
            [0x017a] = { instruc = "res 7, e", size = 2 },
            [0x017c] = { instruc = "res 7, h", size = 2 },
            [0x017e] = { instruc = "res 7, l", size = 2 },
            [0x0180] = { instruc = "res 7, [hl]", size = 2 },
            [0x0182] = { instruc = "set 0, a", size = 2 },
            [0x0184] = { instruc = "set 0, b", size = 2 },
            [0x0186] = { instruc = "set 0, c", size = 2 },
            [0x0188] = { instruc = "set 0, d", size = 2 },
            [0x018a] = { instruc = "set 0, e", size = 2 },
            [0x018c] = { instruc = "set 0, h", size = 2 },
            [0x018e] = { instruc = "set 0, l", size = 2 },
            [0x0190] = { instruc = "set 0, [hl]", size = 2 },
            [0x0192] = { instruc = "set 1, a", size = 2 },
            [0x0194] = { instruc = "set 1, b", size = 2 },
            [0x0196] = { instruc = "set 1, c", size = 2 },
            [0x0198] = { instruc = "set 1, d", size = 2 },
            [0x019a] = { instruc = "set 1, e", size = 2 },
            [0x019c] = { instruc = "set 1, h", size = 2 },
            [0x019e] = { instruc = "set 1, l", size = 2 },
            [0x01a0] = { instruc = "set 1, [hl]", size = 2 },
            [0x01a2] = { instruc = "set 2, a", size = 2 },
            [0x01a4] = { instruc = "set 2, b", size = 2 },
            [0x01a6] = { instruc = "set 2, c", size = 2 },
            [0x01a8] = { instruc = "set 2, d", size = 2 },
            [0x01aa] = { instruc = "set 2, e", size = 2 },
            [0x01ac] = { instruc = "set 2, h", size = 2 },
            [0x01ae] = { instruc = "set 2, l", size = 2 },
            [0x01b0] = { instruc = "set 2, [hl]", size = 2 },
            [0x01b2] = { instruc = "set 3, a", size = 2 },
            [0x01b4] = { instruc = "set 3, b", size = 2 },
            [0x01b6] = { instruc = "set 3, c", size = 2 },
            [0x01b8] = { instruc = "set 3, d", size = 2 },
            [0x01ba] = { instruc = "set 3, e", size = 2 },
            [0x01bc] = { instruc = "set 3, h", size = 2 },
            [0x01be] = { instruc = "set 3, l", size = 2 },
            [0x01c0] = { instruc = "set 3, [hl]", size = 2 },
            [0x01c2] = { instruc = "set 4, a", size = 2 },
            [0x01c4] = { instruc = "set 4, b", size = 2 },
            [0x01c6] = { instruc = "set 4, c", size = 2 },
            [0x01c8] = { instruc = "set 4, d", size = 2 },
            [0x01ca] = { instruc = "set 4, e", size = 2 },
            [0x01cc] = { instruc = "set 4, h", size = 2 },
            [0x01ce] = { instruc = "set 4, l", size = 2 },
            [0x01d0] = { instruc = "set 4, [hl]", size = 2 },
            [0x01d2] = { instruc = "set 5, a", size = 2 },
            [0x01d4] = { instruc = "set 5, b", size = 2 },
            [0x01d6] = { instruc = "set 5, c", size = 2 },
            [0x01d8] = { instruc = "set 5, d", size = 2 },
            [0x01da] = { instruc = "set 5, e", size = 2 },
            [0x01dc] = { instruc = "set 5, h", size = 2 },
            [0x01de] = { instruc = "set 5, l", size = 2 },
            [0x01e0] = { instruc = "set 5, [hl]", size = 2 },
            [0x01e2] = { instruc = "set 6, a", size = 2 },
            [0x01e4] = { instruc = "set 6, b", size = 2 },
            [0x01e6] = { instruc = "set 6, c", size = 2 },
            [0x01e8] = { instruc = "set 6, d", size = 2 },
            [0x01ea] = { instruc = "set 6, e", size = 2 },
            [0x01ec] = { instruc = "set 6, h", size = 2 },
            [0x01ee] = { instruc = "set 6, l", size = 2 },
            [0x01f0] = { instruc = "set 6, [hl]", size = 2 },
            [0x01f2] = { instruc = "set 7, a", size = 2 },
            [0x01f4] = { instruc = "set 7, b", size = 2 },
            [0x01f6] = { instruc = "set 7, c", size = 2 },
            [0x01f8] = { instruc = "set 7, d", size = 2 },
            [0x01fa] = { instruc = "set 7, e", size = 2 },
            [0x01fc] = { instruc = "set 7, h", size = 2 },
            [0x01fe] = { instruc = "set 7, l", size = 2 },
            [0x0200] = { instruc = "set 7, [hl]", size = 2 },
        }, rom.banks[0].instructions)
    end)

    it("reads data", function()
        local rom = Rom:new()
        local sym = Symbols:new()

        sym:add_region_symbol(0, 0, "code", 0x4000)
        rom:read_rom(sym, io.open("./spec/fixtures/non_instructions.gb", "rb"))

        assert.are.same(
            string.char(0xd3)
                .. string.char(0xe3)
                .. string.char(0xe4)
                .. string.char(0xf4)
                .. string.char(0xdb)
                .. string.char(0xeb)
                .. string.char(0xec)
                .. string.char(0xfc)
                .. string.char(0xed)
                .. string.char(0xdd),
            rom.banks[0].data
        )
    end)

    it("reads cut off instruction", function()
        local rom = Rom:new()
        local sym = Symbols:new()

        sym:add_region_symbol(0, 0, "code", 0x4000)
        rom:read_rom(sym, io.open("./spec/fixtures/cut_off_instruction.gb", "rb"))

        assert.are.same({}, rom.banks[0].instructions)
        assert.are.same(string.char(0xcb), rom.banks[0].data)
    end)

    -- TODO: test auto code mapping
    -- TODO: test auto labels
    -- TODO: test auto comments
end)
