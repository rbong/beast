local beast = require("beast")

local create_rom = beast.rom.create_rom
local read_rom = beast.rom.read_rom
local create_instruction = beast.rom.create_instruction

local op = beast.rom.operands

local create_processor_register_operand = beast.rom.create_processor_register_operand
local create_dynamic_byte_operand = beast.rom.create_dynamic_byte_operand
local create_dynamic_octet_operand = beast.rom.create_dynamic_octet_operand

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
         create_instruction("ret")
      })
   end)

   it("reads basic instructions", function()
      local rom = create_rom()
      read_rom(rom, io.open("./spec/fixtures/basic_instructions.gb", "rb"))
      assert.are.same(rom.banks[0].instructions, {
            -- nop
            create_instruction("nop"),
            -- halt
            create_instruction("halt"),
            -- di
            create_instruction("di"),
            -- ei
            create_instruction("ei"),
            -- ld a, a
            create_instruction("ld", op.a_register, op.a_register),
            -- ld a, b
            create_instruction("ld", op.a_register, op.b_register),
            -- ld a, c
            create_instruction("ld", op.a_register, op.c_register),
            -- ld a, d
            create_instruction("ld", op.a_register, op.d_register),
            -- ld a, e
            create_instruction("ld", op.a_register, op.e_register),
            -- ld a, h
            create_instruction("ld", op.a_register, op.f_register),
            -- ld a, l
            create_instruction("ld", op.a_register, op.l_register),
            -- ld b, a
            create_instruction("ld", op.b_register, op.a_register),
            -- ld b, b
            create_instruction("ld", op.b_register, op.b_register),
            -- ld b, c
            create_instruction("ld", op.b_register, op.c_register),
            -- ld b, d
            create_instruction("ld", op.b_register, op.d_register),
            -- ld b, e
            create_instruction("ld", op.b_register, op.e_register),
            -- ld b, h
            create_instruction("ld", op.b_register, op.h_register),
            -- ld b, l
            create_instruction("ld", op.b_register, op.l_register),
            -- ld c, a
            create_instruction("ld", op.c_register, op.a_register),
            -- ld c, b
            create_instruction("ld", op.c_register, op.b_register),
            -- ld c, c
            create_instruction("ld", op.c_register, op.c_register),
            -- ld c, d
            create_instruction("ld", op.c_register, op.d_register),
            -- ld c, e
            create_instruction("ld", op.c_register, op.e_register),
            -- ld c, h
            create_instruction("ld", op.c_register, op.h_register),
            -- ld c, l
            create_instruction("ld", op.c_register, op.l_register),
            -- ld d, a
            create_instruction("ld", op.d_register, op.a_register),
            -- ld d, b
            create_instruction("ld", op.d_register, op.b_register),
            -- ld d, c
            create_instruction("ld", op.d_register, op.c_register),
            -- ld d, d
            create_instruction("ld", op.d_register, op.d_register),
            -- ld d, e
            create_instruction("ld", op.d_register, op.e_register),
            -- ld d, h
            create_instruction("ld", op.d_register, op.h_register),
            -- ld d, l
            create_instruction("ld", op.d_register, op.l_register),
            -- ld e, a
            create_instruction("ld", op.e_register, op.a_register),
            -- ld e, b
            create_instruction("ld", op.e_register, op.b_register),
            -- ld e, c
            create_instruction("ld", op.e_register, op.c_register),
            -- ld e, d
            create_instruction("ld", op.e_register, op.d_register),
            -- ld e, e
            create_instruction("ld", op.e_register, op.e_register),
            -- ld e, h
            create_instruction("ld", op.e_register, op.h_register),
            -- ld e, l
            create_instruction("ld", op.e_register, op.l_register),
            -- ld h, a
            create_instruction("ld", op.h_register, op.a_register),
            -- ld h, b
            create_instruction("ld", op.h_register, op.b_register),
            -- ld h, c
            create_instruction("ld", op.h_register, op.c_register),
            -- ld h, d
            create_instruction("ld", op.h_register, op.d_register),
            -- ld h, e
            create_instruction("ld", op.h_register, op.e_register),
            -- ld h, h
            create_instruction("ld", op.h_register, op.h_register),
            -- ld h, l
            create_instruction("ld", op.h_register, op.l_register),
            -- ld l, a
            create_instruction("ld", op.l_register, op.a_register),
            -- ld l, b
            create_instruction("ld", op.l_register, op.b_register),
            -- ld l, c
            create_instruction("ld", op.l_register, op.c_register),
            -- ld l, d
            create_instruction("ld", op.l_register, op.d_register),
            -- ld l, e
            create_instruction("ld", op.l_register, op.e_register),
            -- ld l, h
            create_instruction("ld", op.l_register, op.h_register),
            -- ld l, l
            create_instruction("ld", op.l_register, op.l_register),
            -- ld a, [hl]
            create_instruction("ld", op.a_register, op.hl_register_set_reference),
            -- ld b, [hl]
            create_instruction("ld", op.b_register, op.hl_register_set_reference),
            -- ld c, [hl]
            create_instruction("ld", op.c_register, op.hl_register_set_reference),
            -- ld d, [hl]
            create_instruction("ld", op.d_register, op.hl_register_set_reference),
            -- ld e, [hl]
            create_instruction("ld", op.e_register, op.hl_register_set_reference),
            -- ld h, [hl]
            create_instruction("ld", op.h_register, op.hl_register_set_reference),
            -- ld l, [hl]
            create_instruction("ld", op.l_register, op.hl_register_set_reference),
            -- ld [hl], a
            create_instruction("ld", op.hl_register_set_reference, op.a_register),
            -- ld [hl], b
            create_instruction("ld", op.hl_register_set_reference, op.b_register),
            -- ld [hl], c
            create_instruction("ld", op.hl_register_set_reference, op.c_register),
            -- ld [hl], d
            create_instruction("ld", op.hl_register_set_reference, op.d_register),
            -- ld [hl], e
            create_instruction("ld", op.hl_register_set_reference, op.e_register),
            -- ld [hl], h
            create_instruction("ld", op.hl_register_set_reference, op.h_register),
            -- ld [hl], l
            create_instruction("ld", op.hl_register_set_reference, op.l_register),
            -- ld a, [$ff00+c]
            create_instruction("ld", op.a_register, op.c_register_hram_offset_reference),
            -- ld [$ff00+c], a
            create_instruction("ld", op.c_register_hram_offset_reference, op.a_register),
            -- ld a, [hl+]
            create_instruction("ld", op.a_register, op.hl_inc_register_set_reference),
            -- ld a, [hl-]
            create_instruction("ld", op.a_register, op.hl_dec_register_set_reference),
            -- ld a, [bc]
            create_instruction("ld", op.a_register, op.bc_register_set_reference),
            -- ld a, [de]
            create_instruction("ld", op.a_register, op.de_register_set_reference),
            -- ld [hl+], a
            create_instruction("ld", op.hl_inc_register_set_reference, op.a_register),
            -- ld [hl-], a
            create_instruction("ld", op.hl_dec_register_set_reference, op.a_register),
            -- ld [bc], a
            create_instruction("ld", op.bc_register_set_reference, op.a_register),
            -- ld [de], a
            create_instruction("ld", op.de_register_set_reference, op.a_register),
            -- add a, a
            create_instruction("add", op.a_register, op.a_register),
            -- add a, b
            create_instruction("add", op.a_register, op.b_register),
            -- add a, c
            create_instruction("add", op.a_register, op.c_register),
            -- add a, d
            create_instruction("add", op.a_register, op.d_register),
            -- add a, e
            create_instruction("add", op.a_register, op.e_register),
            -- add a, h
            create_instruction("add", op.a_register, op.h_register),
            -- add a, l
            create_instruction("add", op.a_register, op.l_register),
            -- add a, [hl]
            create_instruction("add", op.a_register, op.hl_register_set_reference),
            -- adc a, a
            create_instruction("adc", op.a_register, op.a_register),
            -- adc a, b
            create_instruction("adc", op.a_register, op.b_register),
            -- adc a, c
            create_instruction("adc", op.a_register, op.c_register),
            -- adc a, d
            create_instruction("adc", op.a_register, op.d_register),
            -- adc a, e
            create_instruction("adc", op.a_register, op.e_register),
            -- adc a, h
            create_instruction("adc", op.a_register, op.h_register),
            -- adc a, l
            create_instruction("adc", op.a_register, op.l_register),
            -- adc a, [hl]
            create_instruction("adc", op.a_register, op.hl_register_set_reference),
            -- sub a, a
            create_instruction("sub", op.a_register, op.a_register),
            -- sub a, b
            create_instruction("sub", op.a_register, op.b_register),
            -- sub a, c
            create_instruction("sub", op.a_register, op.c_register),
            -- sub a, d
            create_instruction("sub", op.a_register, op.d_register),
            -- sub a, e
            create_instruction("sub", op.a_register, op.e_register),
            -- sub a, h
            create_instruction("sub", op.a_register, op.h_register),
            -- sub a, l
            create_instruction("sub", op.a_register, op.l_register),
            -- sub a, [hl]
            create_instruction("sub", op.a_register, op.hl_register_set_reference),
            -- sbc a, a
            create_instruction("sbc", op.a_register, op.a_register),
            -- sbc a, b
            create_instruction("sbc", op.a_register, op.b_register),
            -- sbc a, c
            create_instruction("sbc", op.a_register, op.c_register),
            -- sbc a, d
            create_instruction("sbc", op.a_register, op.d_register),
            -- sbc a, e
            create_instruction("sbc", op.a_register, op.e_register),
            -- sbc a, h
            create_instruction("sbc", op.a_register, op.h_register),
            -- sbc a, l
            create_instruction("sbc", op.a_register, op.l_register),
            -- sbc a, [hl]
            create_instruction("sbc", op.a_register, op.hl_register_set_reference),
            -- sbc a, d8
            create_instruction("sbc", op.hl_register_set, op.hl_register_set),
            -- add hl, hl
            create_instruction("sbc", op.hl_register_set, op.bc_register_set),
            -- add hl, bc
            create_instruction("sbc", op.hl_register_set, op.de_register_set),
            -- daa
            create_instruction("daa"),
            -- scf
            create_instruction("scf"),
            -- and a, a
            create_instruction("and", op.a_register, op.a_register),
            -- and a, b
            create_instruction("and", op.a_register, op.b_register),
            -- and a, c
            create_instruction("and", op.a_register, op.c_register),
            -- and a, d
            create_instruction("and", op.a_register, op.d_register),
            -- and a, e
            create_instruction("and", op.a_register, op.e_register),
            -- and a, h
            create_instruction("and", op.a_register, op.h_register),
            -- and a, l
            create_instruction("and", op.a_register, op.l_register),
            -- and a, [hl]
            create_instruction("and", op.a_register, op.hl_register_set_reference),
            -- xor a, a
            create_instruction("xor", op.a_register, op.a_register),
            -- xor a, b
            create_instruction("xor", op.a_register, op.b_register),
            -- xor a, c
            create_instruction("xor", op.a_register, op.c_register),
            -- xor a, d
            create_instruction("xor", op.a_register, op.d_register),
            -- xor a, e
            create_instruction("xor", op.a_register, op.e_register),
            -- xor a, h
            create_instruction("xor", op.a_register, op.h_register),
            -- xor a, l
            create_instruction("xor", op.a_register, op.l_register),
            -- xor a, [hl]
            create_instruction("xor", op.a_register, op.hl_register_set_reference),
            -- or a, a
            create_instruction("or", op.a_register, op.a_register),
            -- or a, b
            create_instruction("or", op.a_register, op.b_register),
            -- or a, c
            create_instruction("or", op.a_register, op.c_register),
            -- or a, d
            create_instruction("or", op.a_register, op.d_register),
            -- or a, e
            create_instruction("or", op.a_register, op.e_register),
            -- or a, h
            create_instruction("or", op.a_register, op.h_register),
            -- or a, l
            create_instruction("or", op.a_register, op.l_register),
            -- or a, [hl]
            create_instruction("or", op.a_register, op.hl_register_set_reference),
            -- cp a, a
            create_instruction("cp", op.a_register, op.a_register),
            -- cp a, b
            create_instruction("cp", op.a_register, op.b_register),
            -- cp a, c
            create_instruction("cp", op.a_register, op.c_register),
            -- cp a, d
            create_instruction("cp", op.a_register, op.d_register),
            -- cp a, e
            create_instruction("cp", op.a_register, op.e_register),
            -- cp a, h
            create_instruction("cp", op.a_register, op.h_register),
            -- cp a, l
            create_instruction("cp", op.a_register, op.l_register),
            -- cp a, [hl]
            create_instruction("cp", op.a_register, op.hl_register_set_reference),
            -- cpl
            create_instruction("cpl"),
            -- ccf
            create_instruction("ccf"),
            -- rlca
            create_instruction("rlca"),
            -- rla
            create_instruction("rla"),
            -- rrca
            create_instruction("rrca"),
            -- rra
            create_instruction("rra"),
            -- inc a
            create_instruction("inc", op.a_register),
            -- inc b
            create_instruction("inc", op.b_register),
            -- inc c
            create_instruction("inc", op.c_register),
            -- inc d
            create_instruction("inc", op.d_register),
            -- inc e
            create_instruction("inc", op.e_register),
            -- inc h
            create_instruction("inc", op.h_register),
            -- inc l
            create_instruction("inc", op.l_register),
            -- inc hl
            create_instruction("inc", op.hl_register_set),
            -- inc bc
            create_instruction("inc", op.bc_register_set),
            -- inc de
            create_instruction("inc", op.de_register_set),
            -- inc [hl]
            create_instruction("inc", op.hl_register_set_reference),
            -- dec a
            create_instruction("dec", op.a_register),
            -- dec b
            create_instruction("dec", op.b_register),
            -- dec c
            create_instruction("dec", op.c_register),
            -- dec d
            create_instruction("dec", op.d_register),
            -- dec e
            create_instruction("dec", op.e_register),
            -- dec h
            create_instruction("dec", op.h_register),
            -- dec l
            create_instruction("dec", op.l_register),
            -- dec hl
            create_instruction("dec", op.hl_register_set),
            -- dec bc
            create_instruction("dec", op.bc_register_set),
            -- dec de
            create_instruction("dec", op.de_register_set),
            -- dec [hl]
            create_instruction("dec", op.hl_register_set_reference),
            -- push af
            create_instruction("push", op.af_register_set),
            -- push bc
            create_instruction("push", op.bc_register_set),
            -- push de
            create_instruction("push", op.de_register_set),
            -- push hl
            create_instruction("push", op.hl_register_set),
            -- pop af
            create_instruction("pop", op.af_register_set),
            -- pop bc
            create_instruction("pop", op.bc_register_set),
            -- pop de
            create_instruction("pop", op.de_register_set),
            -- pop hl
            create_instruction("pop", op.hl_register_set),
            -- inc sp
            create_instruction("inc", op.sp_register),
            -- dec sp
            create_instruction("dec", op.sp_register),
            -- ld sp, hl
            create_instruction("ld", op.sp_register, op.hl_register_set),
            -- add hl, sp
            create_instruction("add", op.hl_register_set, op.sp_register),
            -- jp a16
            create_instruction("jp", op.hl_register_set_reference),
            -- rst 00h
            create_instruction("rst", op.vector_00h),
            -- rst 08h
            create_instruction("rst", op.vector_08h),
            -- rst 10h
            create_instruction("rst", op.vector_10h),
            -- rst 18h
            create_instruction("rst", op.vector_18h),
            -- rst 20h
            create_instruction("rst", op.vector_20h),
            -- rst 28h
            create_instruction("rst", op.vector_28h),
            -- rst 30h
            create_instruction("rst", op.vector_30h),
            -- rst 38h
            create_instruction("rst", op.vector_38h),
            -- ret
            create_instruction("ret"),
            -- reti
            create_instruction("reti"),
            -- ret c
            create_instruction("ret", op.c_condition),
            -- ret z
            create_instruction("ret", op.z_condition),
            -- ret nc
            create_instruction("ret", op.nc_condition),
            -- ret nz
            create_instruction("ret", op.nz_condition)
      })
   end)

   it("reads instructions with a dynamic byte operand", function()
      local rom = create_rom()
      read_rom(rom, io.open("./spec/fixtures/byte_op_instructions.gb", "rb"))
      assert.are.same(rom.banks[0].instructions, {
            -- ld a, d8
            create_instruction("ld", op.a_register, create_dynamic_byte_operand(0x00), 2),
            -- ld b, d8
            create_instruction("ld", op.b_register, create_dynamic_byte_operand(0x10), 2),
            -- ld c, d8
            create_instruction("ld", op.c_register, create_dynamic_byte_operand(0x20), 2),
            -- ld d, d8
            create_instruction("ld", op.d_register, create_dynamic_byte_operand(0x30), 2),
            -- ld e, d8
            create_instruction("ld", op.e_register, create_dynamic_byte_operand(0x40), 2),
            -- ld h, d8
            create_instruction("ld", op.h_register, create_dynamic_byte_operand(0x50), 2),
            -- ld l, d8
            create_instruction("ld", op.l_register, create_dynamic_byte_operand(0x60), 2),
            -- ldio a, [$ff00+a8]
            create_instruction("ldio", op.a_register, create_dynamic_byte_operand(0x70, true, false, 0xff00), 2),
            -- ldio [$ff00+a8], a
            create_instruction("ldio", create_dynamic_byte_operand(0x80, true, false, 0xff00), op.a_register, 2),
            -- ld [hl], d8
            create_instruction("ld", op.hl_register_set_reference, create_dynamic_byte_operand(0x90), 2),
            -- add a, d8
            create_instruction("add", op.a_register, create_dynamic_byte_operand(0xa0), 2),
            -- adc a, d8
            create_instruction("adc", op.a_register, create_dynamic_byte_operand(0xb0), 2),
            -- sub a, d8
            create_instruction("sub", op.a_register, create_dynamic_byte_operand(0xc0), 2),
            -- sbc a, d8
            create_instruction("sbc", op.a_register, create_dynamic_byte_operand(0xd0), 2),
            -- and a, d8
            create_instruction("and", op.a_register, create_dynamic_byte_operand(0xe0), 2),
            -- xor a, d8
            create_instruction("xor", op.a_register, create_dynamic_byte_operand(0xf0), 2),
            -- or a, d8
            create_instruction("or", op.a_register, create_dynamic_byte_operand(0x01), 2),
            -- cp a, d8
            create_instruction("cp", op.a_register, create_dynamic_byte_operand(0x11), 2),
            -- add sp, a8
            create_instruction("add", op.sp_register, create_dynamic_byte_operand(0x21), 2),
            -- ld hl, sp+a8
            create_instruction("ld", op.hl_register_set, create_processor_register_operand("sp", false, false, 0x31), 2),
            -- TODO: these bytes should actually be negative and relative
            -- jr a8
            create_instruction("jr", create_dynamic_byte_operand(0xfe), nil, 2),
            -- jr c, a8
            create_instruction("jr", op.c_condition, create_dynamic_byte_operand(0xfc), 2),
            -- jr z, a8
            create_instruction("jr", op.z_condition, create_dynamic_byte_operand(0xfa), 2),
            -- jr nc, a8
            create_instruction("jr", op.nc_condition, create_dynamic_byte_operand(0xf8), 2),
            -- jr nz, a8
            create_instruction("jr", op.nz_condition, create_dynamic_byte_operand(0xf6), 2)
      })
   end)

   it("reads instructions with a dynamic octet operand", function()
      local rom = create_rom()
      read_rom(rom, io.open("./spec/fixtures/octet_op_instructions.gb", "rb"))
      assert.are.same(rom.banks[0].instructions, {
            -- ld a, [a16]
            create_instruction("ld", op.a_register, create_dynamic_octet_operand(0x0000, true), 3),
            -- ld [a16], a
            create_instruction("ld", create_dynamic_octet_operand(0x0100, true), op.a_register, 3),
            -- ld hl, d16
            create_instruction("ld", op.hl_register_set, create_dynamic_octet_operand(0x0200), 3),
            -- ld bc, d16
            create_instruction("ld", op.bc_register_set, create_dynamic_octet_operand(0x0300), 3),
            -- ld de, d16
            create_instruction("ld", op.de_register_set, create_dynamic_octet_operand(0x0400), 3),
            -- ld sp, a16
            create_instruction("ld", op.sp_register, create_dynamic_octet_operand(0x0500), 3),
            -- ld [a16], sp
            create_instruction("ld", create_dynamic_octet_operand(0x0600, true), op.sp_register, 3),
            -- call a16
            create_instruction("call", create_dynamic_octet_operand(0x0700), nil, 3),
            -- call c, a16
            create_instruction("call", op.c_condition, create_dynamic_octet_operand(0x0800), 3),
            -- call z, a16
            create_instruction("call", op.z_condition, create_dynamic_octet_operand(0x0900), 3),
            -- call nc, a16
            create_instruction("call", op.nc_condition, create_dynamic_octet_operand(0x0a00), 3),
            -- call nz, a16
            create_instruction("call", op.nz_condition, create_dynamic_octet_operand(0x0b00), 3),
            -- jp a16
            create_instruction("jp", create_dynamic_octet_operand(0x0c00), nil, 3),
            -- jp c, a16
            create_instruction("jp", op.c_condition, create_dynamic_octet_operand(0x0f00), 3),
            -- jp z, a16
            create_instruction("jp", op.z_condition, create_dynamic_octet_operand(0x1000), 3),
            -- jp nc, a16
            create_instruction("jp", op.nc_condition, create_dynamic_octet_operand(0x1100), 3),
            -- jp nz, a16
            create_instruction("jp", op.nz_condition, create_dynamic_octet_operand(0x1200), 3)
      })
   end)

   it("reads extended instructions", function()
      local rom = create_rom()
      read_rom(rom, io.open("./spec/fixtures/extended_instructions.gb", "rb"))
      assert.are.same(rom.banks[0].instructions, {
            -- stop
            create_instruction("stop", create_dynamic_byte_operand(0), nil, 2),
            -- rlc a
            create_instruction("rlc", op.a_register, nil, 2),
            -- rlc b
            create_instruction("rlc", op.b_register, nil, 2),
            -- rlc c
            create_instruction("rlc", op.c_register, nil, 2),
            -- rlc d
            create_instruction("rlc", op.d_register, nil, 2),
            -- rlc e
            create_instruction("rlc", op.e_register, nil, 2),
            -- rlc h
            create_instruction("rlc", op.h_register, nil, 2),
            -- rlc l
            create_instruction("rlc", op.l_register, nil, 2),
            -- rlc [hl]
            create_instruction("rlc", op.hl_register_set_reference, nil, 2),
            -- rrc a
            create_instruction("rrc", op.a_register, nil, 2),
            -- rrc b
            create_instruction("rrc", op.b_register, nil, 2),
            -- rrc c
            create_instruction("rrc", op.c_register, nil, 2),
            -- rrc d
            create_instruction("rrc", op.d_register, nil, 2),
            -- rrc e
            create_instruction("rrc", op.e_register, nil, 2),
            -- rrc h
            create_instruction("rrc", op.h_register, nil, 2),
            -- rrc l
            create_instruction("rrc", op.l_register, nil, 2),
            -- rrc [hl]
            create_instruction("rrc", op.hl_register_set_reference, nil, 2),
            -- rl a
            create_instruction("rl", op.a_register, nil, 2),
            -- rl b
            create_instruction("rl", op.b_register, nil, 2),
            -- rl c
            create_instruction("rl", op.c_register, nil, 2),
            -- rl d
            create_instruction("rl", op.d_register, nil, 2),
            -- rl e
            create_instruction("rl", op.e_register, nil, 2),
            -- rl h
            create_instruction("rl", op.h_register, nil, 2),
            -- rl l
            create_instruction("rl", op.l_register, nil, 2),
            -- rl [hl]
            create_instruction("rl", op.hl_register_set_reference, nil, 2),
            -- rr a
            create_instruction("rr", op.a_register, nil, 2),
            -- rr b
            create_instruction("rr", op.b_register, nil, 2),
            -- rr c
            create_instruction("rr", op.c_register, nil, 2),
            -- rr d
            create_instruction("rr", op.d_register, nil, 2),
            -- rr e
            create_instruction("rr", op.e_register, nil, 2),
            -- rr h
            create_instruction("rr", op.h_register, nil, 2),
            -- rr l
            create_instruction("rr", op.l_register, nil, 2),
            -- rr [hl]
            create_instruction("rr", op.hl_register_set_reference, nil, 2),
            -- sla a
            create_instruction("sla", op.a_register, nil, 2),
            -- sla b
            create_instruction("sla", op.b_register, nil, 2),
            -- sla c
            create_instruction("sla", op.c_register, nil, 2),
            -- sla d
            create_instruction("sla", op.d_register, nil, 2),
            -- sla e
            create_instruction("sla", op.e_register, nil, 2),
            -- sla h
            create_instruction("sla", op.h_register, nil, 2),
            -- sla l
            create_instruction("sla", op.l_register, nil, 2),
            -- sla [hl]
            create_instruction("sla", op.hl_register_set_reference, nil, 2),
            -- sra a
            create_instruction("sra", op.a_register, nil, 2),
            -- sra b
            create_instruction("sra", op.b_register, nil, 2),
            -- sra c
            create_instruction("sra", op.c_register, nil, 2),
            -- sra d
            create_instruction("sra", op.d_register, nil, 2),
            -- sra e
            create_instruction("sra", op.e_register, nil, 2),
            -- sra h
            create_instruction("sra", op.h_register, nil, 2),
            -- sra l
            create_instruction("sra", op.l_register, nil, 2),
            -- sra [hl]
            create_instruction("sra", op.hl_register_set_reference, nil, 2),
            -- swap a
            create_instruction("swap", op.a_register, nil, 2),
            -- swap b
            create_instruction("swap", op.b_register, nil, 2),
            -- swap c
            create_instruction("swap", op.c_register, nil, 2),
            -- swap d
            create_instruction("swap", op.d_register, nil, 2),
            -- swap e
            create_instruction("swap", op.e_register, nil, 2),
            -- swap h
            create_instruction("swap", op.h_register, nil, 2),
            -- swap l
            create_instruction("swap", op.l_register, nil, 2),
            -- swap [hl]
            create_instruction("swap", op.hl_register_set_reference, nil, 2),
            -- srl a
            create_instruction("srl", op.a_register, nil, 2),
            -- srl b
            create_instruction("srl", op.b_register, nil, 2),
            -- srl c
            create_instruction("srl", op.c_register, nil, 2),
            -- srl d
            create_instruction("srl", op.d_register, nil, 2),
            -- srl e
            create_instruction("srl", op.e_register, nil, 2),
            -- srl h
            create_instruction("srl", op.h_register, nil, 2),
            -- srl l
            create_instruction("srl", op.l_register, nil, 2),
            -- srl [hl]
            create_instruction("srl", op.hl_register_set_reference, nil, 2),
            -- bit 0, a
            create_instruction("bit", create_dynamic_byte_operand(0), op.a_register, 2),
            -- bit 0, b
            create_instruction("bit", create_dynamic_byte_operand(0), op.b_register, 2),
            -- bit 0, c
            create_instruction("bit", create_dynamic_byte_operand(0), op.c_register, 2),
            -- bit 0, d
            create_instruction("bit", create_dynamic_byte_operand(0), op.d_register, 2),
            -- bit 0, e
            create_instruction("bit", create_dynamic_byte_operand(0), op.e_register, 2),
            -- bit 0, h
            create_instruction("bit", create_dynamic_byte_operand(0), op.h_register, 2),
            -- bit 0, l
            create_instruction("bit", create_dynamic_byte_operand(0), op.l_register, 2),
            -- bit 0, [hl]
            create_instruction("bit", create_dynamic_byte_operand(0), op.hl_register_set_reference, 2),
            -- bit 1, a
            create_instruction("bit", create_dynamic_byte_operand(1), op.a_register, 2),
            -- bit 1, b
            create_instruction("bit", create_dynamic_byte_operand(1), op.b_register, 2),
            -- bit 1, c
            create_instruction("bit", create_dynamic_byte_operand(1), op.c_register, 2),
            -- bit 1, d
            create_instruction("bit", create_dynamic_byte_operand(1), op.d_register, 2),
            -- bit 1, e
            create_instruction("bit", create_dynamic_byte_operand(1), op.e_register, 2),
            -- bit 1, h
            create_instruction("bit", create_dynamic_byte_operand(1), op.h_register, 2),
            -- bit 1, l
            create_instruction("bit", create_dynamic_byte_operand(1), op.l_register, 2),
            -- bit 1, [hl]
            create_instruction("bit", create_dynamic_byte_operand(1), op.hl_register_set_reference, 2),
            -- bit 2, a
            create_instruction("bit", create_dynamic_byte_operand(2), op.a_register, 2),
            -- bit 2, b
            create_instruction("bit", create_dynamic_byte_operand(2), op.b_register, 2),
            -- bit 2, c
            create_instruction("bit", create_dynamic_byte_operand(2), op.c_register, 2),
            -- bit 2, d
            create_instruction("bit", create_dynamic_byte_operand(2), op.d_register, 2),
            -- bit 2, e
            create_instruction("bit", create_dynamic_byte_operand(2), op.e_register, 2),
            -- bit 2, h
            create_instruction("bit", create_dynamic_byte_operand(2), op.h_register, 2),
            -- bit 2, l
            create_instruction("bit", create_dynamic_byte_operand(2), op.l_register, 2),
            -- bit 2, [hl]
            create_instruction("bit", create_dynamic_byte_operand(2), op.hl_register_set_reference, 2),
            -- bit 3, a
            create_instruction("bit", create_dynamic_byte_operand(3), op.a_register, 2),
            -- bit 3, b
            create_instruction("bit", create_dynamic_byte_operand(3), op.b_register, 2),
            -- bit 3, c
            create_instruction("bit", create_dynamic_byte_operand(3), op.c_register, 2),
            -- bit 3, d
            create_instruction("bit", create_dynamic_byte_operand(3), op.d_register, 2),
            -- bit 3, e
            create_instruction("bit", create_dynamic_byte_operand(3), op.e_register, 2),
            -- bit 3, h
            create_instruction("bit", create_dynamic_byte_operand(3), op.h_register, 2),
            -- bit 3, l
            create_instruction("bit", create_dynamic_byte_operand(3), op.l_register, 2),
            -- bit 3, [hl]
            create_instruction("bit", create_dynamic_byte_operand(3), op.hl_register_set_reference, 2),
            -- bit 4, a
            create_instruction("bit", create_dynamic_byte_operand(4), op.a_register, 2),
            -- bit 4, b
            create_instruction("bit", create_dynamic_byte_operand(4), op.b_register, 2),
            -- bit 4, c
            create_instruction("bit", create_dynamic_byte_operand(4), op.c_register, 2),
            -- bit 4, d
            create_instruction("bit", create_dynamic_byte_operand(4), op.d_register, 2),
            -- bit 4, e
            create_instruction("bit", create_dynamic_byte_operand(4), op.e_register, 2),
            -- bit 4, h
            create_instruction("bit", create_dynamic_byte_operand(4), op.h_register, 2),
            -- bit 4, l
            create_instruction("bit", create_dynamic_byte_operand(4), op.l_register, 2),
            -- bit 4, [hl]
            create_instruction("bit", create_dynamic_byte_operand(4), op.hl_register_set_reference, 2),
            -- bit 5, a
            create_instruction("bit", create_dynamic_byte_operand(5), op.a_register, 2),
            -- bit 5, b
            create_instruction("bit", create_dynamic_byte_operand(5), op.b_register, 2),
            -- bit 5, c
            create_instruction("bit", create_dynamic_byte_operand(5), op.c_register, 2),
            -- bit 5, d
            create_instruction("bit", create_dynamic_byte_operand(5), op.d_register, 2),
            -- bit 5, e
            create_instruction("bit", create_dynamic_byte_operand(5), op.e_register, 2),
            -- bit 5, h
            create_instruction("bit", create_dynamic_byte_operand(5), op.h_register, 2),
            -- bit 5, l
            create_instruction("bit", create_dynamic_byte_operand(5), op.l_register, 2),
            -- bit 5, [hl]
            create_instruction("bit", create_dynamic_byte_operand(5), op.hl_register_set_reference, 2),
            -- bit 6, a
            create_instruction("bit", create_dynamic_byte_operand(6), op.a_register, 2),
            -- bit 6, b
            create_instruction("bit", create_dynamic_byte_operand(6), op.b_register, 2),
            -- bit 6, c
            create_instruction("bit", create_dynamic_byte_operand(6), op.c_register, 2),
            -- bit 6, d
            create_instruction("bit", create_dynamic_byte_operand(6), op.d_register, 2),
            -- bit 6, e
            create_instruction("bit", create_dynamic_byte_operand(6), op.e_register, 2),
            -- bit 6, h
            create_instruction("bit", create_dynamic_byte_operand(6), op.h_register, 2),
            -- bit 6, l
            create_instruction("bit", create_dynamic_byte_operand(6), op.l_register, 2),
            -- bit 6, [hl]
            create_instruction("bit", create_dynamic_byte_operand(6), op.hl_register_set_reference, 2),
            -- bit 7, a
            create_instruction("bit", create_dynamic_byte_operand(7), op.a_register, 2),
            -- bit 7, b
            create_instruction("bit", create_dynamic_byte_operand(7), op.b_register, 2),
            -- bit 7, c
            create_instruction("bit", create_dynamic_byte_operand(7), op.c_register, 2),
            -- bit 7, d
            create_instruction("bit", create_dynamic_byte_operand(7), op.d_register, 2),
            -- bit 7, e
            create_instruction("bit", create_dynamic_byte_operand(7), op.e_register, 2),
            -- bit 7, h
            create_instruction("bit", create_dynamic_byte_operand(7), op.h_register, 2),
            -- bit 7, l
            create_instruction("bit", create_dynamic_byte_operand(7), op.l_register, 2),
            -- bit 7, [hl]
            create_instruction("bit", create_dynamic_byte_operand(7), op.hl_register_set_reference, 2),
            -- res 0, a
            create_instruction("res", create_dynamic_byte_operand(0), op.a_register, 2),
            -- res 0, b
            create_instruction("res", create_dynamic_byte_operand(0), op.b_register, 2),
            -- res 0, c
            create_instruction("res", create_dynamic_byte_operand(0), op.c_register, 2),
            -- res 0, d
            create_instruction("res", create_dynamic_byte_operand(0), op.d_register, 2),
            -- res 0, e
            create_instruction("res", create_dynamic_byte_operand(0), op.e_register, 2),
            -- res 0, h
            create_instruction("res", create_dynamic_byte_operand(0), op.h_register, 2),
            -- res 0, l
            create_instruction("res", create_dynamic_byte_operand(0), op.l_register, 2),
            -- res 0, [hl]
            create_instruction("res", create_dynamic_byte_operand(0), op.hl_register_set_reference, 2),
            -- res 1, a
            create_instruction("res", create_dynamic_byte_operand(1), op.a_register, 2),
            -- res 1, b
            create_instruction("res", create_dynamic_byte_operand(1), op.b_register, 2),
            -- res 1, c
            create_instruction("res", create_dynamic_byte_operand(1), op.c_register, 2),
            -- res 1, d
            create_instruction("res", create_dynamic_byte_operand(1), op.d_register, 2),
            -- res 1, e
            create_instruction("res", create_dynamic_byte_operand(1), op.e_register, 2),
            -- res 1, h
            create_instruction("res", create_dynamic_byte_operand(1), op.h_register, 2),
            -- res 1, l
            create_instruction("res", create_dynamic_byte_operand(1), op.l_register, 2),
            -- res 1, [hl]
            create_instruction("res", create_dynamic_byte_operand(1), op.hl_register_set_reference, 2),
            -- res 2, a
            create_instruction("res", create_dynamic_byte_operand(2), op.a_register, 2),
            -- res 2, b
            create_instruction("res", create_dynamic_byte_operand(2), op.b_register, 2),
            -- res 2, c
            create_instruction("res", create_dynamic_byte_operand(2), op.c_register, 2),
            -- res 2, d
            create_instruction("res", create_dynamic_byte_operand(2), op.d_register, 2),
            -- res 2, e
            create_instruction("res", create_dynamic_byte_operand(2), op.e_register, 2),
            -- res 2, h
            create_instruction("res", create_dynamic_byte_operand(2), op.h_register, 2),
            -- res 2, l
            create_instruction("res", create_dynamic_byte_operand(2), op.l_register, 2),
            -- res 2, [hl]
            create_instruction("res", create_dynamic_byte_operand(2), op.hl_register_set_reference, 2),
            -- res 3, a
            create_instruction("res", create_dynamic_byte_operand(3), op.a_register, 2),
            -- res 3, b
            create_instruction("res", create_dynamic_byte_operand(3), op.b_register, 2),
            -- res 3, c
            create_instruction("res", create_dynamic_byte_operand(3), op.c_register, 2),
            -- res 3, d
            create_instruction("res", create_dynamic_byte_operand(3), op.d_register, 2),
            -- res 3, e
            create_instruction("res", create_dynamic_byte_operand(3), op.e_register, 2),
            -- res 3, h
            create_instruction("res", create_dynamic_byte_operand(3), op.h_register, 2),
            -- res 3, l
            create_instruction("res", create_dynamic_byte_operand(3), op.l_register, 2),
            -- res 3, [hl]
            create_instruction("res", create_dynamic_byte_operand(3), op.hl_register_set_reference, 2),
            -- res 4, a
            create_instruction("res", create_dynamic_byte_operand(4), op.a_register, 2),
            -- res 4, b
            create_instruction("res", create_dynamic_byte_operand(4), op.b_register, 2),
            -- res 4, c
            create_instruction("res", create_dynamic_byte_operand(4), op.c_register, 2),
            -- res 4, d
            create_instruction("res", create_dynamic_byte_operand(4), op.d_register, 2),
            -- res 4, e
            create_instruction("res", create_dynamic_byte_operand(4), op.e_register, 2),
            -- res 4, h
            create_instruction("res", create_dynamic_byte_operand(4), op.h_register, 2),
            -- res 4, l
            create_instruction("res", create_dynamic_byte_operand(4), op.l_register, 2),
            -- res 4, [hl]
            create_instruction("res", create_dynamic_byte_operand(4), op.hl_register_set_reference, 2),
            -- res 5, a
            create_instruction("res", create_dynamic_byte_operand(5), op.a_register, 2),
            -- res 5, b
            create_instruction("res", create_dynamic_byte_operand(5), op.b_register, 2),
            -- res 5, c
            create_instruction("res", create_dynamic_byte_operand(5), op.c_register, 2),
            -- res 5, d
            create_instruction("res", create_dynamic_byte_operand(5), op.d_register, 2),
            -- res 5, e
            create_instruction("res", create_dynamic_byte_operand(5), op.e_register, 2),
            -- res 5, h
            create_instruction("res", create_dynamic_byte_operand(5), op.h_register, 2),
            -- res 5, l
            create_instruction("res", create_dynamic_byte_operand(5), op.l_register, 2),
            -- res 5, [hl]
            create_instruction("res", create_dynamic_byte_operand(5), op.hl_register_set_reference, 2),
            -- res 6, a
            create_instruction("res", create_dynamic_byte_operand(6), op.a_register, 2),
            -- res 6, b
            create_instruction("res", create_dynamic_byte_operand(6), op.b_register, 2),
            -- res 6, c
            create_instruction("res", create_dynamic_byte_operand(6), op.c_register, 2),
            -- res 6, d
            create_instruction("res", create_dynamic_byte_operand(6), op.d_register, 2),
            -- res 6, e
            create_instruction("res", create_dynamic_byte_operand(6), op.e_register, 2),
            -- res 6, h
            create_instruction("res", create_dynamic_byte_operand(6), op.h_register, 2),
            -- res 6, l
            create_instruction("res", create_dynamic_byte_operand(6), op.l_register, 2),
            -- res 6, [hl]
            create_instruction("res", create_dynamic_byte_operand(6), op.hl_register_set_reference, 2),
            -- res 7, a
            create_instruction("res", create_dynamic_byte_operand(7), op.a_register, 2),
            -- res 7, b
            create_instruction("res", create_dynamic_byte_operand(7), op.b_register, 2),
            -- res 7, c
            create_instruction("res", create_dynamic_byte_operand(7), op.c_register, 2),
            -- res 7, d
            create_instruction("res", create_dynamic_byte_operand(7), op.d_register, 2),
            -- res 7, e
            create_instruction("res", create_dynamic_byte_operand(7), op.e_register, 2),
            -- res 7, h
            create_instruction("res", create_dynamic_byte_operand(7), op.h_register, 2),
            -- res 7, l
            create_instruction("res", create_dynamic_byte_operand(7), op.l_register, 2),
            -- res 7, [hl]
            create_instruction("res", create_dynamic_byte_operand(7), op.hl_register_set_reference, 2),
            -- set 0, a
            create_instruction("set", create_dynamic_byte_operand(0), op.a_register, 2),
            -- set 0, b
            create_instruction("set", create_dynamic_byte_operand(0), op.b_register, 2),
            -- set 0, c
            create_instruction("set", create_dynamic_byte_operand(0), op.c_register, 2),
            -- set 0, d
            create_instruction("set", create_dynamic_byte_operand(0), op.d_register, 2),
            -- set 0, e
            create_instruction("set", create_dynamic_byte_operand(0), op.e_register, 2),
            -- set 0, h
            create_instruction("set", create_dynamic_byte_operand(0), op.h_register, 2),
            -- set 0, l
            create_instruction("set", create_dynamic_byte_operand(0), op.l_register, 2),
            -- set 0, [hl]
            create_instruction("set", create_dynamic_byte_operand(0), op.hl_register_set_reference, 2),
            -- set 1, a
            create_instruction("set", create_dynamic_byte_operand(1), op.a_register, 2),
            -- set 1, b
            create_instruction("set", create_dynamic_byte_operand(1), op.b_register, 2),
            -- set 1, c
            create_instruction("set", create_dynamic_byte_operand(1), op.c_register, 2),
            -- set 1, d
            create_instruction("set", create_dynamic_byte_operand(1), op.d_register, 2),
            -- set 1, e
            create_instruction("set", create_dynamic_byte_operand(1), op.e_register, 2),
            -- set 1, h
            create_instruction("set", create_dynamic_byte_operand(1), op.h_register, 2),
            -- set 1, l
            create_instruction("set", create_dynamic_byte_operand(1), op.l_register, 2),
            -- set 1, [hl]
            create_instruction("set", create_dynamic_byte_operand(1), op.hl_register_set_reference, 2),
            -- set 2, a
            create_instruction("set", create_dynamic_byte_operand(2), op.a_register, 2),
            -- set 2, b
            create_instruction("set", create_dynamic_byte_operand(2), op.b_register, 2),
            -- set 2, c
            create_instruction("set", create_dynamic_byte_operand(2), op.c_register, 2),
            -- set 2, d
            create_instruction("set", create_dynamic_byte_operand(2), op.d_register, 2),
            -- set 2, e
            create_instruction("set", create_dynamic_byte_operand(2), op.e_register, 2),
            -- set 2, h
            create_instruction("set", create_dynamic_byte_operand(2), op.h_register, 2),
            -- set 2, l
            create_instruction("set", create_dynamic_byte_operand(2), op.l_register, 2),
            -- set 2, [hl]
            create_instruction("set", create_dynamic_byte_operand(2), op.hl_register_set_reference, 2),
            -- set 3, a
            create_instruction("set", create_dynamic_byte_operand(3), op.a_register, 2),
            -- set 3, b
            create_instruction("set", create_dynamic_byte_operand(3), op.b_register, 2),
            -- set 3, c
            create_instruction("set", create_dynamic_byte_operand(3), op.c_register, 2),
            -- set 3, d
            create_instruction("set", create_dynamic_byte_operand(3), op.d_register, 2),
            -- set 3, e
            create_instruction("set", create_dynamic_byte_operand(3), op.e_register, 2),
            -- set 3, h
            create_instruction("set", create_dynamic_byte_operand(3), op.h_register, 2),
            -- set 3, l
            create_instruction("set", create_dynamic_byte_operand(3), op.l_register, 2),
            -- set 3, [hl]
            create_instruction("set", create_dynamic_byte_operand(3), op.hl_register_set_reference, 2),
            -- set 4, a
            create_instruction("set", create_dynamic_byte_operand(4), op.a_register, 2),
            -- set 4, b
            create_instruction("set", create_dynamic_byte_operand(4), op.b_register, 2),
            -- set 4, c
            create_instruction("set", create_dynamic_byte_operand(4), op.c_register, 2),
            -- set 4, d
            create_instruction("set", create_dynamic_byte_operand(4), op.d_register, 2),
            -- set 4, e
            create_instruction("set", create_dynamic_byte_operand(4), op.e_register, 2),
            -- set 4, h
            create_instruction("set", create_dynamic_byte_operand(4), op.h_register, 2),
            -- set 4, l
            create_instruction("set", create_dynamic_byte_operand(4), op.l_register, 2),
            -- set 4, [hl]
            create_instruction("set", create_dynamic_byte_operand(4), op.hl_register_set_reference, 2),
            -- set 5, a
            create_instruction("set", create_dynamic_byte_operand(5), op.a_register, 2),
            -- set 5, b
            create_instruction("set", create_dynamic_byte_operand(5), op.b_register, 2),
            -- set 5, c
            create_instruction("set", create_dynamic_byte_operand(5), op.c_register, 2),
            -- set 5, d
            create_instruction("set", create_dynamic_byte_operand(5), op.d_register, 2),
            -- set 5, e
            create_instruction("set", create_dynamic_byte_operand(5), op.e_register, 2),
            -- set 5, h
            create_instruction("set", create_dynamic_byte_operand(5), op.h_register, 2),
            -- set 5, l
            create_instruction("set", create_dynamic_byte_operand(5), op.l_register, 2),
            -- set 5, [hl]
            create_instruction("set", create_dynamic_byte_operand(5), op.hl_register_set_reference, 2),
            -- set 6, a
            create_instruction("set", create_dynamic_byte_operand(6), op.a_register, 2),
            -- set 6, b
            create_instruction("set", create_dynamic_byte_operand(6), op.b_register, 2),
            -- set 6, c
            create_instruction("set", create_dynamic_byte_operand(6), op.c_register, 2),
            -- set 6, d
            create_instruction("set", create_dynamic_byte_operand(6), op.d_register, 2),
            -- set 6, e
            create_instruction("set", create_dynamic_byte_operand(6), op.e_register, 2),
            -- set 6, h
            create_instruction("set", create_dynamic_byte_operand(6), op.h_register, 2),
            -- set 6, l
            create_instruction("set", create_dynamic_byte_operand(6), op.l_register, 2),
            -- set 6, [hl]
            create_instruction("set", create_dynamic_byte_operand(6), op.hl_register_set_reference, 2),
            -- set 7, a
            create_instruction("set", create_dynamic_byte_operand(7), op.a_register, 2),
            -- set 7, b
            create_instruction("set", create_dynamic_byte_operand(7), op.b_register, 2),
            -- set 7, c
            create_instruction("set", create_dynamic_byte_operand(7), op.c_register, 2),
            -- set 7, d
            create_instruction("set", create_dynamic_byte_operand(7), op.d_register, 2),
            -- set 7, e
            create_instruction("set", create_dynamic_byte_operand(7), op.e_register, 2),
            -- set 7, h
            create_instruction("set", create_dynamic_byte_operand(7), op.h_register, 2),
            -- set 7, l
            create_instruction("set", create_dynamic_byte_operand(7), op.l_register, 2),
            -- set 7, [hl]
            create_instruction("set", create_dynamic_byte_operand(7), op.hl_register_set_reference, 2)
      })
   end)
end)
