local beast = require("beast")

local create_rom = beast.rom.create_rom
local read_rom = beast.rom.read_rom

local op = beast.rom.operands

describe("Rom", function()
   it("reads a bank", function()
      local rom = create_rom()
      read_rom(rom, io.open("./spec/fixtures/ret.gb", "rb"))
      assert.truthy(rom.nbanks == 1)
   end)

   it("reads a bank byte", function()
      local rom = create_rom()
      read_rom(rom, io.open("./spec/fixtures/ret.gb", "rb"))
      assert.truthy(rom.banks[0].size == 1)
   end)

   it("reads ret instruction", function()
      local rom = create_rom()
      read_rom(rom, io.open("./spec/fixtures/ret.gb", "rb"))
      assert.are.same(rom.banks[0].instructions, {
         { code = "ret", size = 1 }
      })
   end)

   it("reads basic instructions", function()
      local rom = create_rom()
      read_rom(rom, io.open("./spec/fixtures/basic_instructions.gb", "rb"))
      assert.are.same(rom.banks[0].instructions, {
            -- nop
            { code = "nop", size = 1 },
            -- halt
            { code = "halt", size = 1 },
            -- di
            { code = "di", size = 1 },
            -- ei
            { code = "ei", size = 1 },
            -- ld a, a
            { code = "ld", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- ld a, b
            { code = "ld", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- ld a, c
            { code = "ld", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- ld a, d
            { code = "ld", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- ld a, e
            { code = "ld", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- ld a, h
            { code = "ld", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "f", size = 1 }, size = 1 },
            -- ld a, l
            { code = "ld", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- ld b, a
            { code = "ld", l_op = { is_register = true, value = "b", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- ld b, b
            { code = "ld", l_op = { is_register = true, value = "b", size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- ld b, c
            { code = "ld", l_op = { is_register = true, value = "b", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- ld b, d
            { code = "ld", l_op = { is_register = true, value = "b", size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- ld b, e
            { code = "ld", l_op = { is_register = true, value = "b", size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- ld b, h
            { code = "ld", l_op = { is_register = true, value = "b", size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- ld b, l
            { code = "ld", l_op = { is_register = true, value = "b", size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- ld c, a
            { code = "ld", l_op = { is_register = true, value = "c", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- ld c, b
            { code = "ld", l_op = { is_register = true, value = "c", size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- ld c, c
            { code = "ld", l_op = { is_register = true, value = "c", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- ld c, d
            { code = "ld", l_op = { is_register = true, value = "c", size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- ld c, e
            { code = "ld", l_op = { is_register = true, value = "c", size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- ld c, h
            { code = "ld", l_op = { is_register = true, value = "c", size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- ld c, l
            { code = "ld", l_op = { is_register = true, value = "c", size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- ld d, a
            { code = "ld", l_op = { is_register = true, value = "d", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- ld d, b
            { code = "ld", l_op = { is_register = true, value = "d", size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- ld d, c
            { code = "ld", l_op = { is_register = true, value = "d", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- ld d, d
            { code = "ld", l_op = { is_register = true, value = "d", size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- ld d, e
            { code = "ld", l_op = { is_register = true, value = "d", size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- ld d, h
            { code = "ld", l_op = { is_register = true, value = "d", size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- ld d, l
            { code = "ld", l_op = { is_register = true, value = "d", size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- ld e, a
            { code = "ld", l_op = { is_register = true, value = "e", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- ld e, b
            { code = "ld", l_op = { is_register = true, value = "e", size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- ld e, c
            { code = "ld", l_op = { is_register = true, value = "e", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- ld e, d
            { code = "ld", l_op = { is_register = true, value = "e", size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- ld e, e
            { code = "ld", l_op = { is_register = true, value = "e", size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- ld e, h
            { code = "ld", l_op = { is_register = true, value = "e", size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- ld e, l
            { code = "ld", l_op = { is_register = true, value = "e", size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- ld h, a
            { code = "ld", l_op = { is_register = true, value = "h", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- ld h, b
            { code = "ld", l_op = { is_register = true, value = "h", size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- ld h, c
            { code = "ld", l_op = { is_register = true, value = "h", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- ld h, d
            { code = "ld", l_op = { is_register = true, value = "h", size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- ld h, e
            { code = "ld", l_op = { is_register = true, value = "h", size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- ld h, h
            { code = "ld", l_op = { is_register = true, value = "h", size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- ld h, l
            { code = "ld", l_op = { is_register = true, value = "h", size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- ld l, a
            { code = "ld", l_op = { is_register = true, value = "l", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- ld l, b
            { code = "ld", l_op = { is_register = true, value = "l", size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- ld l, c
            { code = "ld", l_op = { is_register = true, value = "l", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- ld l, d
            { code = "ld", l_op = { is_register = true, value = "l", size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- ld l, e
            { code = "ld", l_op = { is_register = true, value = "l", size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- ld l, h
            { code = "ld", l_op = { is_register = true, value = "l", size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- ld l, l
            { code = "ld", l_op = { is_register = true, value = "l", size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- ld a, [hl]
            { code = "ld", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- ld b, [hl]
            { code = "ld", l_op = { is_register = true, value = "b", size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- ld c, [hl]
            { code = "ld", l_op = { is_register = true, value = "c", size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- ld d, [hl]
            { code = "ld", l_op = { is_register = true, value = "d", size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- ld e, [hl]
            { code = "ld", l_op = { is_register = true, value = "e", size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- ld h, [hl]
            { code = "ld", l_op = { is_register = true, value = "h", size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- ld l, [hl]
            { code = "ld", l_op = { is_register = true, value = "l", size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- ld [hl], a
            { code = "ld", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- ld [hl], b
            { code = "ld", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- ld [hl], c
            { code = "ld", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- ld [hl], d
            { code = "ld", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- ld [hl], e
            { code = "ld", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- ld [hl], h
            { code = "ld", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- ld [hl], l
            { code = "ld", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- ld a, [$ff00+c]
            { code = "ld", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, reference = true, offset = 0xff00, value = "c", size = 1 }, size = 1 },
            -- ld [$ff00+c], a
            { code = "ld", l_op = { is_register = true, reference = true, offset = 0xff00, value = "c", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- ld a, [hl+]
            { code = "ld", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, reference = true, increment = 1, value = "hl", size = 2 }, size = 1 },
            -- ld a, [hl-]
            { code = "ld", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, reference = true, increment = -1, value = "hl", size = 2 }, size = 1 },
            -- ld a, [bc]
            { code = "ld", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, reference = true, value = "bc", size = 2 }, size = 1 },
            -- ld a, [de]
            { code = "ld", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, reference = true, value = "de", size = 2 }, size = 1 },
            -- ld [hl+], a
            { code = "ld", l_op = { is_register = true, reference = true, increment = 1, value = "hl", size = 2 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- ld [hl-], a
            { code = "ld", l_op = { is_register = true, reference = true, increment = -1, value = "hl", size = 2 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- ld [bc], a
            { code = "ld", l_op = { is_register = true, reference = true, value = "bc", size = 2 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- ld [de], a
            { code = "ld", l_op = { is_register = true, reference = true, value = "de", size = 2 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- add a, a
            { code = "add", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- add a, b
            { code = "add", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- add a, c
            { code = "add", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- add a, d
            { code = "add", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- add a, e
            { code = "add", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- add a, h
            { code = "add", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- add a, l
            { code = "add", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- add a, [hl]
            { code = "add", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- adc a, a
            { code = "adc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- adc a, b
            { code = "adc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- adc a, c
            { code = "adc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- adc a, d
            { code = "adc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- adc a, e
            { code = "adc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- adc a, h
            { code = "adc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- adc a, l
            { code = "adc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- adc a, [hl]
            { code = "adc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- sub a, a
            { code = "sub", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- sub a, b
            { code = "sub", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- sub a, c
            { code = "sub", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- sub a, d
            { code = "sub", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- sub a, e
            { code = "sub", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- sub a, h
            { code = "sub", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- sub a, l
            { code = "sub", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- sub a, [hl]
            { code = "sub", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- sbc a, a
            { code = "sbc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- sbc a, b
            { code = "sbc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- sbc a, c
            { code = "sbc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- sbc a, d
            { code = "sbc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- sbc a, e
            { code = "sbc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- sbc a, h
            { code = "sbc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- sbc a, l
            { code = "sbc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- sbc a, [hl]
            { code = "sbc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- sbc a, n8
            { code = "sbc", l_op = { is_register = true, value = "hl", size = 2 }, r_op = { is_register = true, value = "hl", size = 2 }, size = 1 },
            -- add hl, hl
            { code = "sbc", l_op = { is_register = true, value = "hl", size = 2 }, r_op = { is_register = true, value = "bc", size = 2 }, size = 1 },
            -- add hl, bc
            { code = "sbc", l_op = { is_register = true, value = "hl", size = 2 }, r_op = { is_register = true, value = "de", size = 2 }, size = 1 },
            -- daa
            { code = "daa", size = 1 },
            -- scf
            { code = "scf", size = 1 },
            -- and a, a
            { code = "and", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- and a, b
            { code = "and", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- and a, c
            { code = "and", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- and a, d
            { code = "and", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- and a, e
            { code = "and", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- and a, h
            { code = "and", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- and a, l
            { code = "and", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- and a, [hl]
            { code = "and", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- xor a, a
            { code = "xor", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- xor a, b
            { code = "xor", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- xor a, c
            { code = "xor", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- xor a, d
            { code = "xor", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- xor a, e
            { code = "xor", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- xor a, h
            { code = "xor", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- xor a, l
            { code = "xor", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- xor a, [hl]
            { code = "xor", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- or a, a
            { code = "or", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- or a, b
            { code = "or", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- or a, c
            { code = "or", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- or a, d
            { code = "or", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- or a, e
            { code = "or", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- or a, h
            { code = "or", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- or a, l
            { code = "or", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- or a, [hl]
            { code = "or", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- cp a, a
            { code = "cp", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- cp a, b
            { code = "cp", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- cp a, c
            { code = "cp", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- cp a, d
            { code = "cp", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- cp a, e
            { code = "cp", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- cp a, h
            { code = "cp", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- cp a, l
            { code = "cp", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- cp a, [hl]
            { code = "cp", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- cpl
            { code = "cpl", size = 1 },
            -- ccf
            { code = "ccf", size = 1 },
            -- rlca
            { code = "rlca", size = 1 },
            -- rla
            { code = "rla", size = 1 },
            -- rrca
            { code = "rrca", size = 1 },
            -- rra
            { code = "rra", size = 1 },
            -- inc a
            { code = "inc", l_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- inc b
            { code = "inc", l_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- inc c
            { code = "inc", l_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- inc d
            { code = "inc", l_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- inc e
            { code = "inc", l_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- inc h
            { code = "inc", l_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- inc l
            { code = "inc", l_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- inc hl
            { code = "inc", l_op = { is_register = true, value = "hl", size = 2 }, size = 1 },
            -- inc bc
            { code = "inc", l_op = { is_register = true, value = "bc", size = 2 }, size = 1 },
            -- inc de
            { code = "inc", l_op = { is_register = true, value = "de", size = 2 }, size = 1 },
            -- inc [hl]
            { code = "inc", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- dec a
            { code = "dec", l_op = { is_register = true, value = "a", size = 1 }, size = 1 },
            -- dec b
            { code = "dec", l_op = { is_register = true, value = "b", size = 1 }, size = 1 },
            -- dec c
            { code = "dec", l_op = { is_register = true, value = "c", size = 1 }, size = 1 },
            -- dec d
            { code = "dec", l_op = { is_register = true, value = "d", size = 1 }, size = 1 },
            -- dec e
            { code = "dec", l_op = { is_register = true, value = "e", size = 1 }, size = 1 },
            -- dec h
            { code = "dec", l_op = { is_register = true, value = "h", size = 1 }, size = 1 },
            -- dec l
            { code = "dec", l_op = { is_register = true, value = "l", size = 1 }, size = 1 },
            -- dec hl
            { code = "dec", l_op = { is_register = true, value = "hl", size = 2 }, size = 1 },
            -- dec bc
            { code = "dec", l_op = { is_register = true, value = "bc", size = 2 }, size = 1 },
            -- dec de
            { code = "dec", l_op = { is_register = true, value = "de", size = 2 }, size = 1 },
            -- dec [hl]
            { code = "dec", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- push af
            { code = "push", l_op = { is_register = true, value = "af", size = 2 }, size = 1 },
            -- push bc
            { code = "push", l_op = { is_register = true, value = "bc", size = 2 }, size = 1 },
            -- push de
            { code = "push", l_op = { is_register = true, value = "de", size = 2 }, size = 1 },
            -- push hl
            { code = "push", l_op = { is_register = true, value = "hl", size = 2 }, size = 1 },
            -- pop af
            { code = "pop", l_op = { is_register = true, value = "af", size = 2 }, size = 1 },
            -- pop bc
            { code = "pop", l_op = { is_register = true, value = "bc", size = 2 }, size = 1 },
            -- pop de
            { code = "pop", l_op = { is_register = true, value = "de", size = 2 }, size = 1 },
            -- pop hl
            { code = "pop", l_op = { is_register = true, value = "hl", size = 2 }, size = 1 },
            -- inc sp
            { code = "inc", l_op = { is_register = true, value = "sp", size = 1 }, size = 1 },
            -- dec sp
            { code = "dec", l_op = { is_register = true, value = "sp", size = 1 }, size = 1 },
            -- ld sp, hl
            { code = "ld", l_op = { is_register = true, value = "sp", size = 1 }, r_op = { is_register = true, value = "hl", size = 2 }, size = 1 },
            -- add hl, sp
            { code = "add", l_op = { is_register = true, value = "hl", size = 2 }, r_op = { is_register = true, value = "sp", size = 1 }, size = 1 },
            -- jp n16
            { code = "jp", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 1 },
            -- rst 00h
            { code = "rst", l_op = { is_vector = true, value = 0x00, size = 1 }, size = 1 },
            -- rst 08h
            { code = "rst", l_op = { is_vector = true, value = 0x08, size = 1 }, size = 1 },
            -- rst 10h
            { code = "rst", l_op = { is_vector = true, value = 0x10, size = 1 }, size = 1 },
            -- rst 18h
            { code = "rst", l_op = { is_vector = true, value = 0x18, size = 1 }, size = 1 },
            -- rst 20h
            { code = "rst", l_op = { is_vector = true, value = 0x20, size = 1 }, size = 1 },
            -- rst 28h
            { code = "rst", l_op = { is_vector = true, value = 0x28, size = 1 }, size = 1 },
            -- rst 30h
            { code = "rst", l_op = { is_vector = true, value = 0x30, size = 1 }, size = 1 },
            -- rst 38h
            { code = "rst", l_op = { is_vector = true, value = 0x38, size = 1 }, size = 1 },
            -- ret
            { code = "ret", size = 1 },
            -- reti
            { code = "reti", size = 1 },
            -- ret c
            { code = "ret", l_op = { is_condition = true, value = "c", size = 1 }, size = 1 },
            -- ret z
            { code = "ret", l_op = { is_condition = true, value = "z", size = 1 }, size = 1 },
            -- ret nc
            { code = "ret", l_op = { is_condition = true, value = "nc", size = 1 }, size = 1 },
            -- ret nz
            { code = "ret", l_op = { is_condition = true, value = "nz", size = 1 }, size = 1 }
      })
   end)

   it("reads instructions with a dynamic byte operand", function()
      local rom = create_rom()
      read_rom(rom, io.open("./spec/fixtures/byte_op_instructions.gb", "rb"))
      assert.are.same(rom.banks[0].instructions, {
            -- ld a, n8
            { code = "ld", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_dynamic = true, value = 0x00, size = 1 }, size = 2 },
            -- ld b, n8
            { code = "ld", l_op = { is_register = true, value = "b", size = 1 }, r_op = { is_dynamic = true, value = 0x10, size = 1 }, size = 2 },
            -- ld c, n8
            { code = "ld", l_op = { is_register = true, value = "c", size = 1 }, r_op = { is_dynamic = true, value = 0x20, size = 1 }, size = 2 },
            -- ld d, n8
            { code = "ld", l_op = { is_register = true, value = "d", size = 1 }, r_op = { is_dynamic = true, value = 0x30, size = 1 }, size = 2 },
            -- ld e, n8
            { code = "ld", l_op = { is_register = true, value = "e", size = 1 }, r_op = { is_dynamic = true, value = 0x40, size = 1 }, size = 2 },
            -- ld h, n8
            { code = "ld", l_op = { is_register = true, value = "h", size = 1 }, r_op = { is_dynamic = true, value = 0x50, size = 1 }, size = 2 },
            -- ld l, n8
            { code = "ld", l_op = { is_register = true, value = "l", size = 1 }, r_op = { is_dynamic = true, value = 0x60, size = 1 }, size = 2 },
            -- ldio a, [$ff00+n8]
            { code = "ldio", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_dynamic = true, reference = true, value= 0x70, offset = 0xff00, size = 1 }, size = 2 },
            -- ldio [$ff00+n8], a
            { code = "ldio", l_op = { is_dynamic = true, reference = true, value= 0x80, offset = 0xff00, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- ld [hl], n8
            { code = "ld", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = { is_dynamic = true, value = 0x90, size = 1 }, size = 2 },
            -- add a, n8
            { code = "add", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_dynamic = true, value = 0xa0, size = 1 }, size = 2 },
            -- adc a, n8
            { code = "adc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_dynamic = true, value = 0xb0, size = 1 }, size = 2 },
            -- sub a, n8
            { code = "sub", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_dynamic = true, value = 0xc0, size = 1 }, size = 2 },
            -- sbc a, n8
            { code = "sbc", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_dynamic = true, value = 0xd0, size = 1 }, size = 2 },
            -- and a, n8
            { code = "and", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_dynamic = true, value = 0xe0, size = 1 }, size = 2 },
            -- xor a, n8
            { code = "xor", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_dynamic = true, value = 0xf0, size = 1 }, size = 2 },
            -- or a, n8
            { code = "or", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_dynamic = true, value = 0x01, size = 1 }, size = 2 },
            -- cp a, n8
            { code = "cp", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_dynamic = true, value = 0x11, size = 1 }, size = 2 },
            -- add sp, e8
            { code = "add", l_op = { is_register = true, value = "sp", size = 1 }, r_op = { is_dynamic = true, signed = true, value = 0x21, size = 1 }, size = 2 },
            -- ld hl, sp+e8
            { code = "ld", l_op = { is_register = true, value = "hl", size = 2 }, r_op = { is_dynamic = true, signed = true, offset = "sp", value = 0x31, size = 1 }, size = 2 },
            -- jr e8
            { code = "jr", l_op = { is_dynamic = true, signed = true, value = 0xfe, size = 1 }, r_op = nil, size = 2 },
            -- jr c, e8
            { code = "jr", l_op = { is_condition = true, value = "c", size = 1 }, r_op = { is_dynamic = true, signed = true, value = 0xfc, size = 1 }, size = 2 },
            -- jr z, e8
            { code = "jr", l_op = { is_condition = true, value = "z", size = 1 }, r_op = { is_dynamic = true, signed = true, value = 0xfa, size = 1 }, size = 2 },
            -- jr nc, e8
            { code = "jr", l_op = { is_condition = true, value = "nc", size = 1 }, r_op = { is_dynamic = true, signed = true, value = 0xf8, size = 1 }, size = 2 },
            -- jr nz, e8
            { code = "jr", l_op = { is_condition = true, value = "nz", size = 1 }, r_op = { is_dynamic = true, signed = true, value = 0xf6, size = 1 }, size = 2 }
      })
   end)

   it("reads instructions with a dynamic octet operand", function()
      local rom = create_rom()
      read_rom(rom, io.open("./spec/fixtures/octet_op_instructions.gb", "rb"))
      assert.are.same(rom.banks[0].instructions, {
            -- ld a, [n16]
            { code = "ld", l_op = { is_register = true, value = "a", size = 1 }, r_op = { is_dynamic = true, reference = true, value = 0x0000, size = 2 }, size = 3 },
            -- ld [n16], a
            { code = "ld", l_op = { is_dynamic = true, reference = true, value = 0x0100, size = 2 }, r_op = { is_register = true, value = "a", size = 1 }, size = 3 },
            -- ld hl, n8
            { code = "ld", l_op = { is_register = true, value = "hl", size = 2 }, r_op = { is_dynamic = true, value = 0x0200, size = 2 }, size = 3 },
            -- ld bc, n8
            { code = "ld", l_op = { is_register = true, value = "bc", size = 2 }, r_op = { is_dynamic = true, value = 0x0300, size = 2 }, size = 3 },
            -- ld de, n8
            { code = "ld", l_op = { is_register = true, value = "de", size = 2 }, r_op = { is_dynamic = true, value = 0x0400, size = 2 }, size = 3 },
            -- ld sp, n16
            { code = "ld", l_op = { is_register = true, value = "sp", size = 1 }, r_op = { is_dynamic = true, value = 0x0500, size = 2 }, size = 3 },
            -- ld [n16], sp
            { code = "ld", l_op = { is_dynamic = true, reference = true, value = 0x0600, size = 2 }, r_op = { is_register = true, value = "sp", size = 1 }, size = 3 },
            -- call n16
            { code = "call", l_op = { is_dynamic = true, value = 0x0700, size = 2 }, r_op = nil, size = 3 },
            -- call c, n16
            { code = "call", l_op = { is_condition = true, value = "c", size = 1 }, r_op = { is_dynamic = true, value = 0x0800, size = 2 }, size = 3 },
            -- call z, n16
            { code = "call", l_op = { is_condition = true, value = "z", size = 1 }, r_op = { is_dynamic = true, value = 0x0900, size = 2 }, size = 3 },
            -- call nc, n16
            { code = "call", l_op = { is_condition = true, value = "nc", size = 1 }, r_op = { is_dynamic = true, value = 0x0a00, size = 2 }, size = 3 },
            -- call nz, n16
            { code = "call", l_op = { is_condition = true, value = "nz", size = 1 }, r_op = { is_dynamic = true, value = 0x0b00, size = 2 }, size = 3 },
            -- jp n16
            { code = "jp", l_op = { is_dynamic = true, value = 0x0c00, size = 2 }, r_op = nil, size = 3 },
            -- jp c, n16
            { code = "jp", l_op = { is_condition = true, value = "c", size = 1 }, r_op = { is_dynamic = true, value = 0x0f00, size = 2 }, size = 3 },
            -- jp z, n16
            { code = "jp", l_op = { is_condition = true, value = "z", size = 1 }, r_op = { is_dynamic = true, value = 0x1000, size = 2 }, size = 3 },
            -- jp nc, n16
            { code = "jp", l_op = { is_condition = true, value = "nc", size = 1 }, r_op = { is_dynamic = true, value = 0x1100, size = 2 }, size = 3 },
            -- jp nz, n16
            { code = "jp", l_op = { is_condition = true, value = "nz", size = 1 }, r_op = { is_dynamic = true, value = 0x1200, size = 2 }, size = 3 }
      })
   end)

   it("reads extended instructions", function()
      local rom = create_rom()
      read_rom(rom, io.open("./spec/fixtures/extended_instructions.gb", "rb"))
      assert.are.same(rom.banks[0].instructions, {
            -- stop
            { code = "stop", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = nil, size = 2 },
            -- rlc a
            { code = "rlc", l_op = { is_register = true, value = "a", size = 1 }, r_op = nil, size = 2 },
            -- rlc b
            { code = "rlc", l_op = { is_register = true, value = "b", size = 1 }, r_op = nil, size = 2 },
            -- rlc c
            { code = "rlc", l_op = { is_register = true, value = "c", size = 1 }, r_op = nil, size = 2 },
            -- rlc d
            { code = "rlc", l_op = { is_register = true, value = "d", size = 1 }, r_op = nil, size = 2 },
            -- rlc e
            { code = "rlc", l_op = { is_register = true, value = "e", size = 1 }, r_op = nil, size = 2 },
            -- rlc h
            { code = "rlc", l_op = { is_register = true, value = "h", size = 1 }, r_op = nil, size = 2 },
            -- rlc l
            { code = "rlc", l_op = { is_register = true, value = "l", size = 1 }, r_op = nil, size = 2 },
            -- rlc [hl]
            { code = "rlc", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = nil, size = 2 },
            -- rrc a
            { code = "rrc", l_op = { is_register = true, value = "a", size = 1 }, r_op = nil, size = 2 },
            -- rrc b
            { code = "rrc", l_op = { is_register = true, value = "b", size = 1 }, r_op = nil, size = 2 },
            -- rrc c
            { code = "rrc", l_op = { is_register = true, value = "c", size = 1 }, r_op = nil, size = 2 },
            -- rrc d
            { code = "rrc", l_op = { is_register = true, value = "d", size = 1 }, r_op = nil, size = 2 },
            -- rrc e
            { code = "rrc", l_op = { is_register = true, value = "e", size = 1 }, r_op = nil, size = 2 },
            -- rrc h
            { code = "rrc", l_op = { is_register = true, value = "h", size = 1 }, r_op = nil, size = 2 },
            -- rrc l
            { code = "rrc", l_op = { is_register = true, value = "l", size = 1 }, r_op = nil, size = 2 },
            -- rrc [hl]
            { code = "rrc", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = nil, size = 2 },
            -- rl a
            { code = "rl", l_op = { is_register = true, value = "a", size = 1 }, r_op = nil, size = 2 },
            -- rl b
            { code = "rl", l_op = { is_register = true, value = "b", size = 1 }, r_op = nil, size = 2 },
            -- rl c
            { code = "rl", l_op = { is_register = true, value = "c", size = 1 }, r_op = nil, size = 2 },
            -- rl d
            { code = "rl", l_op = { is_register = true, value = "d", size = 1 }, r_op = nil, size = 2 },
            -- rl e
            { code = "rl", l_op = { is_register = true, value = "e", size = 1 }, r_op = nil, size = 2 },
            -- rl h
            { code = "rl", l_op = { is_register = true, value = "h", size = 1 }, r_op = nil, size = 2 },
            -- rl l
            { code = "rl", l_op = { is_register = true, value = "l", size = 1 }, r_op = nil, size = 2 },
            -- rl [hl]
            { code = "rl", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = nil, size = 2 },
            -- rr a
            { code = "rr", l_op = { is_register = true, value = "a", size = 1 }, r_op = nil, size = 2 },
            -- rr b
            { code = "rr", l_op = { is_register = true, value = "b", size = 1 }, r_op = nil, size = 2 },
            -- rr c
            { code = "rr", l_op = { is_register = true, value = "c", size = 1 }, r_op = nil, size = 2 },
            -- rr d
            { code = "rr", l_op = { is_register = true, value = "d", size = 1 }, r_op = nil, size = 2 },
            -- rr e
            { code = "rr", l_op = { is_register = true, value = "e", size = 1 }, r_op = nil, size = 2 },
            -- rr h
            { code = "rr", l_op = { is_register = true, value = "h", size = 1 }, r_op = nil, size = 2 },
            -- rr l
            { code = "rr", l_op = { is_register = true, value = "l", size = 1 }, r_op = nil, size = 2 },
            -- rr [hl]
            { code = "rr", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = nil, size = 2 },
            -- sla a
            { code = "sla", l_op = { is_register = true, value = "a", size = 1 }, r_op = nil, size = 2 },
            -- sla b
            { code = "sla", l_op = { is_register = true, value = "b", size = 1 }, r_op = nil, size = 2 },
            -- sla c
            { code = "sla", l_op = { is_register = true, value = "c", size = 1 }, r_op = nil, size = 2 },
            -- sla d
            { code = "sla", l_op = { is_register = true, value = "d", size = 1 }, r_op = nil, size = 2 },
            -- sla e
            { code = "sla", l_op = { is_register = true, value = "e", size = 1 }, r_op = nil, size = 2 },
            -- sla h
            { code = "sla", l_op = { is_register = true, value = "h", size = 1 }, r_op = nil, size = 2 },
            -- sla l
            { code = "sla", l_op = { is_register = true, value = "l", size = 1 }, r_op = nil, size = 2 },
            -- sla [hl]
            { code = "sla", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = nil, size = 2 },
            -- sra a
            { code = "sra", l_op = { is_register = true, value = "a", size = 1 }, r_op = nil, size = 2 },
            -- sra b
            { code = "sra", l_op = { is_register = true, value = "b", size = 1 }, r_op = nil, size = 2 },
            -- sra c
            { code = "sra", l_op = { is_register = true, value = "c", size = 1 }, r_op = nil, size = 2 },
            -- sra d
            { code = "sra", l_op = { is_register = true, value = "d", size = 1 }, r_op = nil, size = 2 },
            -- sra e
            { code = "sra", l_op = { is_register = true, value = "e", size = 1 }, r_op = nil, size = 2 },
            -- sra h
            { code = "sra", l_op = { is_register = true, value = "h", size = 1 }, r_op = nil, size = 2 },
            -- sra l
            { code = "sra", l_op = { is_register = true, value = "l", size = 1 }, r_op = nil, size = 2 },
            -- sra [hl]
            { code = "sra", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = nil, size = 2 },
            -- swap a
            { code = "swap", l_op = { is_register = true, value = "a", size = 1 }, r_op = nil, size = 2 },
            -- swap b
            { code = "swap", l_op = { is_register = true, value = "b", size = 1 }, r_op = nil, size = 2 },
            -- swap c
            { code = "swap", l_op = { is_register = true, value = "c", size = 1 }, r_op = nil, size = 2 },
            -- swap d
            { code = "swap", l_op = { is_register = true, value = "d", size = 1 }, r_op = nil, size = 2 },
            -- swap e
            { code = "swap", l_op = { is_register = true, value = "e", size = 1 }, r_op = nil, size = 2 },
            -- swap h
            { code = "swap", l_op = { is_register = true, value = "h", size = 1 }, r_op = nil, size = 2 },
            -- swap l
            { code = "swap", l_op = { is_register = true, value = "l", size = 1 }, r_op = nil, size = 2 },
            -- swap [hl]
            { code = "swap", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = nil, size = 2 },
            -- srl a
            { code = "srl", l_op = { is_register = true, value = "a", size = 1 }, r_op = nil, size = 2 },
            -- srl b
            { code = "srl", l_op = { is_register = true, value = "b", size = 1 }, r_op = nil, size = 2 },
            -- srl c
            { code = "srl", l_op = { is_register = true, value = "c", size = 1 }, r_op = nil, size = 2 },
            -- srl d
            { code = "srl", l_op = { is_register = true, value = "d", size = 1 }, r_op = nil, size = 2 },
            -- srl e
            { code = "srl", l_op = { is_register = true, value = "e", size = 1 }, r_op = nil, size = 2 },
            -- srl h
            { code = "srl", l_op = { is_register = true, value = "h", size = 1 }, r_op = nil, size = 2 },
            -- srl l
            { code = "srl", l_op = { is_register = true, value = "l", size = 1 }, r_op = nil, size = 2 },
            -- srl [hl]
            { code = "srl", l_op = { is_register = true, reference = true, value = "hl", size = 2 }, r_op = nil, size = 2 },
            -- bit 0, a
            { code = "bit", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- bit 0, b
            { code = "bit", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- bit 0, c
            { code = "bit", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- bit 0, d
            { code = "bit", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- bit 0, e
            { code = "bit", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- bit 0, h
            { code = "bit", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- bit 0, l
            { code = "bit", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- bit 0, [hl]
            { code = "bit", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- bit 1, a
            { code = "bit", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- bit 1, b
            { code = "bit", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- bit 1, c
            { code = "bit", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- bit 1, d
            { code = "bit", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- bit 1, e
            { code = "bit", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- bit 1, h
            { code = "bit", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- bit 1, l
            { code = "bit", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- bit 1, [hl]
            { code = "bit", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- bit 2, a
            { code = "bit", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- bit 2, b
            { code = "bit", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- bit 2, c
            { code = "bit", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- bit 2, d
            { code = "bit", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- bit 2, e
            { code = "bit", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- bit 2, h
            { code = "bit", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- bit 2, l
            { code = "bit", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- bit 2, [hl]
            { code = "bit", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- bit 3, a
            { code = "bit", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- bit 3, b
            { code = "bit", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- bit 3, c
            { code = "bit", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- bit 3, d
            { code = "bit", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- bit 3, e
            { code = "bit", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- bit 3, h
            { code = "bit", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- bit 3, l
            { code = "bit", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- bit 3, [hl]
            { code = "bit", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- bit 4, a
            { code = "bit", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- bit 4, b
            { code = "bit", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- bit 4, c
            { code = "bit", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- bit 4, d
            { code = "bit", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- bit 4, e
            { code = "bit", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- bit 4, h
            { code = "bit", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- bit 4, l
            { code = "bit", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- bit 4, [hl]
            { code = "bit", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- bit 5, a
            { code = "bit", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- bit 5, b
            { code = "bit", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- bit 5, c
            { code = "bit", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- bit 5, d
            { code = "bit", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- bit 5, e
            { code = "bit", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- bit 5, h
            { code = "bit", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- bit 5, l
            { code = "bit", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- bit 5, [hl]
            { code = "bit", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- bit 6, a
            { code = "bit", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- bit 6, b
            { code = "bit", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- bit 6, c
            { code = "bit", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- bit 6, d
            { code = "bit", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- bit 6, e
            { code = "bit", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- bit 6, h
            { code = "bit", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- bit 6, l
            { code = "bit", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- bit 6, [hl]
            { code = "bit", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- bit 7, a
            { code = "bit", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- bit 7, b
            { code = "bit", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- bit 7, c
            { code = "bit", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- bit 7, d
            { code = "bit", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- bit 7, e
            { code = "bit", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- bit 7, h
            { code = "bit", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- bit 7, l
            { code = "bit", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- bit 7, [hl]
            { code = "bit", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- res 0, a
            { code = "res", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- res 0, b
            { code = "res", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- res 0, c
            { code = "res", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- res 0, d
            { code = "res", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- res 0, e
            { code = "res", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- res 0, h
            { code = "res", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- res 0, l
            { code = "res", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- res 0, [hl]
            { code = "res", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- res 1, a
            { code = "res", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- res 1, b
            { code = "res", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- res 1, c
            { code = "res", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- res 1, d
            { code = "res", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- res 1, e
            { code = "res", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- res 1, h
            { code = "res", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- res 1, l
            { code = "res", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- res 1, [hl]
            { code = "res", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- res 2, a
            { code = "res", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- res 2, b
            { code = "res", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- res 2, c
            { code = "res", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- res 2, d
            { code = "res", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- res 2, e
            { code = "res", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- res 2, h
            { code = "res", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- res 2, l
            { code = "res", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- res 2, [hl]
            { code = "res", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- res 3, a
            { code = "res", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- res 3, b
            { code = "res", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- res 3, c
            { code = "res", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- res 3, d
            { code = "res", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- res 3, e
            { code = "res", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- res 3, h
            { code = "res", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- res 3, l
            { code = "res", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- res 3, [hl]
            { code = "res", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- res 4, a
            { code = "res", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- res 4, b
            { code = "res", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- res 4, c
            { code = "res", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- res 4, d
            { code = "res", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- res 4, e
            { code = "res", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- res 4, h
            { code = "res", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- res 4, l
            { code = "res", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- res 4, [hl]
            { code = "res", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- res 5, a
            { code = "res", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- res 5, b
            { code = "res", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- res 5, c
            { code = "res", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- res 5, d
            { code = "res", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- res 5, e
            { code = "res", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- res 5, h
            { code = "res", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- res 5, l
            { code = "res", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- res 5, [hl]
            { code = "res", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- res 6, a
            { code = "res", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- res 6, b
            { code = "res", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- res 6, c
            { code = "res", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- res 6, d
            { code = "res", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- res 6, e
            { code = "res", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- res 6, h
            { code = "res", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- res 6, l
            { code = "res", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- res 6, [hl]
            { code = "res", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- res 7, a
            { code = "res", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- res 7, b
            { code = "res", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- res 7, c
            { code = "res", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- res 7, d
            { code = "res", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- res 7, e
            { code = "res", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- res 7, h
            { code = "res", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- res 7, l
            { code = "res", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- res 7, [hl]
            { code = "res", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- set 0, a
            { code = "set", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- set 0, b
            { code = "set", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- set 0, c
            { code = "set", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- set 0, d
            { code = "set", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- set 0, e
            { code = "set", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- set 0, h
            { code = "set", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- set 0, l
            { code = "set", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- set 0, [hl]
            { code = "set", l_op = { is_dynamic = true, value = 0, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- set 1, a
            { code = "set", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- set 1, b
            { code = "set", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- set 1, c
            { code = "set", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- set 1, d
            { code = "set", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- set 1, e
            { code = "set", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- set 1, h
            { code = "set", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- set 1, l
            { code = "set", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- set 1, [hl]
            { code = "set", l_op = { is_dynamic = true, value = 1, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- set 2, a
            { code = "set", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- set 2, b
            { code = "set", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- set 2, c
            { code = "set", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- set 2, d
            { code = "set", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- set 2, e
            { code = "set", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- set 2, h
            { code = "set", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- set 2, l
            { code = "set", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- set 2, [hl]
            { code = "set", l_op = { is_dynamic = true, value = 2, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- set 3, a
            { code = "set", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- set 3, b
            { code = "set", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- set 3, c
            { code = "set", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- set 3, d
            { code = "set", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- set 3, e
            { code = "set", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- set 3, h
            { code = "set", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- set 3, l
            { code = "set", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- set 3, [hl]
            { code = "set", l_op = { is_dynamic = true, value = 3, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- set 4, a
            { code = "set", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- set 4, b
            { code = "set", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- set 4, c
            { code = "set", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- set 4, d
            { code = "set", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- set 4, e
            { code = "set", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- set 4, h
            { code = "set", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- set 4, l
            { code = "set", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- set 4, [hl]
            { code = "set", l_op = { is_dynamic = true, value = 4, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- set 5, a
            { code = "set", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- set 5, b
            { code = "set", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- set 5, c
            { code = "set", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- set 5, d
            { code = "set", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- set 5, e
            { code = "set", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- set 5, h
            { code = "set", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- set 5, l
            { code = "set", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- set 5, [hl]
            { code = "set", l_op = { is_dynamic = true, value = 5, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- set 6, a
            { code = "set", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- set 6, b
            { code = "set", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- set 6, c
            { code = "set", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- set 6, d
            { code = "set", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- set 6, e
            { code = "set", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- set 6, h
            { code = "set", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- set 6, l
            { code = "set", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- set 6, [hl]
            { code = "set", l_op = { is_dynamic = true, value = 6, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 },
            -- set 7, a
            { code = "set", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "a", size = 1 }, size = 2 },
            -- set 7, b
            { code = "set", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "b", size = 1 }, size = 2 },
            -- set 7, c
            { code = "set", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "c", size = 1 }, size = 2 },
            -- set 7, d
            { code = "set", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "d", size = 1 }, size = 2 },
            -- set 7, e
            { code = "set", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "e", size = 1 }, size = 2 },
            -- set 7, h
            { code = "set", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "h", size = 1 }, size = 2 },
            -- set 7, l
            { code = "set", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, value = "l", size = 1 }, size = 2 },
            -- set 7, [hl]
            { code = "set", l_op = { is_dynamic = true, value = 7, size = 1 }, r_op = { is_register = true, reference = true, value = "hl", size = 2 }, size = 2 }
      })
   end)

   it("reads data", function()
      local rom = create_rom()
      read_rom(rom, io.open("./spec/fixtures/non_instructions.gb", "rb"))
      assert.are.same(rom.banks[0].instructions, {
            -- All non-instruction bytes
            { code = "db", data = { 0xd3 }, is_data = true, size = 1 },
            { code = "db", data = { 0xe3 }, is_data = true, size = 1 },
            { code = "db", data = { 0xe4 }, is_data = true, size = 1 },
            { code = "db", data = { 0xf4 }, is_data = true, size = 1 },
            { code = "db", data = { 0xdb }, is_data = true, size = 1 },
            { code = "db", data = { 0xeb }, is_data = true, size = 1 },
            { code = "db", data = { 0xec }, is_data = true, size = 1 },
            { code = "db", data = { 0xfc }, is_data = true, size = 1 },
            { code = "db", data = { 0xed }, is_data = true, size = 1 },
            { code = "db", data = { 0xdd }, is_data = true, size = 1 }
      })
   end)

   it("reads cut off instruction", function()
      local rom = create_rom()
      read_rom(rom, io.open("./spec/fixtures/cut_off_instruction.gb", "rb"))
      assert.are.same(rom.banks[0].instructions, {
            { code = "db", data = { 0xcb }, is_data = true, size = 1 }
      })
   end)
end)
