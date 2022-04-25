local operand = require("beast/rom/operand")

local create_processor_register_operand = operand.create_processor_register_operand
local create_dynamic_byte_operand = operand.create_dynamic_byte_operand
local create_dynamic_octet_operand = operand.create_dynamic_octet_operand

-- TODO: handle signed instructions

-- TODO: handle rgbasm halt with nop

-- TODO: handle invalid instructions and do db instead
-- instructions that are too short
-- LDH A [(anything not in HRAM)]
-- LDH [(anything not in HRAM)], A

local op = operand.operands

local function create_instruction(code, l_op, r_op, size)
   return {
      code = code,
      l_op = l_op,
      r_op = r_op,
      size = size or 1
   }
end

local function create_instruction_parser(code, l_op, r_op, size)
   local instruction = create_instruction(code, l_op, r_op, size)

   return {
      size = size or 1,
      read = function ()
         return nil, instruction
      end
   }
end

local function create_extended_instruction_parser(code, l_op, r_op)
   return create_instruction_parser(code, l_op, r_op, 2)
end

local function create_dynamic_op_instruction_parser(code, l_op, r_op, parse_op, size, op_size)
   size = size or 2
   op_size = op_size or 1

   return {
      size = size,
      op_size = op_size,
      read = function (file)
         local bytes = file:read(op_size)
         if not bytes then
            return
         end

         local parsed_op = parse_op(bytes)
         if not parsed_op then
            return bytes
         end

         if l_op == nil then
            return bytes, create_instruction(code, parsed_op, r_op, size)
         else
            return bytes, create_instruction(code, l_op, parsed_op, size)
         end
      end
   }
end

local function create_byte_op_instruction_parser(code, l_op, r_op, reference, offset)
   return create_dynamic_op_instruction_parser(
      code,
      l_op,
      r_op,
      function (byte)
         return create_dynamic_byte_operand(string.byte(byte), reference, false, offset)
      end,
      2,
      1)
end

local function create_octet_op_instruction_parser(code, l_op, r_op, reference)
   return create_dynamic_op_instruction_parser(
      code,
      l_op,
      r_op,
      function (bytes)
         local byte1 = string.byte(bytes)
         if byte1 == nil then
            return nil
         end

         local byte2 = string.byte(bytes, 2)
         if byte2 == nil then
            return nil
         end

         return create_dynamic_octet_operand(byte2 * 0x100 + byte1, reference, false, offset)
      end,
      3,
      2)
end

local function create_sp_offset_op_instruction_parser(code, l_op, r_op, reference)
   return create_dynamic_op_instruction_parser(
      code,
      l_op,
      r_op,
      function (byte)
         return create_processor_register_operand("sp", reference, false, string.byte(byte))
      end,
      2,
      1)
end

local instructions = {
   -- Control Instructions --

   -- nop
   [string.char(0x00)] = create_instruction_parser("nop"),
   -- halt
   [string.char(0x76)] = create_instruction_parser("halt"),
   -- di
   [string.char(0xf3)] = create_instruction_parser("di"),
   -- ei
   [string.char(0xfb)] = create_instruction_parser("ei"),

   -- "ld r8, r8" Instructions --

   -- ld a, a
   [string.char(0x7f)] = create_instruction_parser(
      "ld", op.a_register, op.a_register),
   -- ld a, b
   [string.char(0x78)] = create_instruction_parser(
      "ld", op.a_register, op.b_register),
   -- ld a, c
   [string.char(0x79)] = create_instruction_parser(
      "ld", op.a_register, op.c_register),
   -- ld a, d
   [string.char(0x7a)] = create_instruction_parser(
      "ld", op.a_register, op.d_register),
   -- ld a, e
   [string.char(0x7b)] = create_instruction_parser(
      "ld", op.a_register, op.e_register),
   -- ld a, h
   [string.char(0x7c)] = create_instruction_parser(
      "ld", op.a_register, op.f_register),
   -- ld a, l
   [string.char(0x7d)] = create_instruction_parser(
      "ld", op.a_register, op.l_register),

   -- ld b, a
   [string.char(0x47)] = create_instruction_parser(
      "ld", op.b_register, op.a_register),
   -- ld b, b
   [string.char(0x40)] = create_instruction_parser(
      "ld", op.b_register, op.b_register),
   -- ld b, c
   [string.char(0x41)] = create_instruction_parser(
      "ld", op.b_register, op.c_register),
   -- ld b, d
   [string.char(0x42)] = create_instruction_parser(
      "ld", op.b_register, op.d_register),
   -- ld b, e
   [string.char(0x43)] = create_instruction_parser(
      "ld", op.b_register, op.e_register),
   -- ld b, h
   [string.char(0x44)] = create_instruction_parser(
      "ld", op.b_register, op.h_register),
   -- ld b, l
   [string.char(0x45)] = create_instruction_parser(
      "ld", op.b_register, op.l_register),

   -- ld c, a
   [string.char(0x4f)] = create_instruction_parser(
      "ld", op.c_register, op.a_register),
   -- ld c, b
   [string.char(0x48)] = create_instruction_parser(
      "ld", op.c_register, op.b_register),
   -- ld c, c
   [string.char(0x49)] = create_instruction_parser(
      "ld", op.c_register, op.c_register),
   -- ld c, d
   [string.char(0x4a)] = create_instruction_parser(
      "ld", op.c_register, op.d_register),
   -- ld c, e
   [string.char(0x4b)] = create_instruction_parser(
      "ld", op.c_register, op.e_register),
   -- ld c, h
   [string.char(0x4c)] = create_instruction_parser(
      "ld", op.c_register, op.h_register),
   -- ld c, l
   [string.char(0x4d)] = create_instruction_parser(
      "ld", op.c_register, op.l_register),

   -- ld d, a
   [string.char(0x57)] = create_instruction_parser(
      "ld", op.d_register, op.a_register),
   -- ld d, b
   [string.char(0x50)] = create_instruction_parser(
      "ld", op.d_register, op.b_register),
   -- ld d, c
   [string.char(0x51)] = create_instruction_parser(
      "ld", op.d_register, op.c_register),
   -- ld d, d
   [string.char(0x52)] = create_instruction_parser(
      "ld", op.d_register, op.d_register),
   -- ld d, e
   [string.char(0x53)] = create_instruction_parser(
      "ld", op.d_register, op.e_register),
   -- ld d, h
   [string.char(0x54)] = create_instruction_parser(
      "ld", op.d_register, op.h_register),
   -- ld d, l
   [string.char(0x55)] = create_instruction_parser(
      "ld", op.d_register, op.l_register),

   -- ld e, a
   [string.char(0x5f)] = create_instruction_parser(
      "ld", op.e_register, op.a_register),
   -- ld e, b
   [string.char(0x58)] = create_instruction_parser(
      "ld", op.e_register, op.b_register),
   -- ld e, c
   [string.char(0x59)] = create_instruction_parser(
      "ld", op.e_register, op.c_register),
   -- ld e, d
   [string.char(0x5a)] = create_instruction_parser(
      "ld", op.e_register, op.d_register),
   -- ld e, e
   [string.char(0x5b)] = create_instruction_parser(
      "ld", op.e_register, op.e_register),
   -- ld e, h
   [string.char(0x5c)] = create_instruction_parser(
      "ld", op.e_register, op.h_register),
   -- ld e, l
   [string.char(0x5d)] = create_instruction_parser(
      "ld", op.e_register, op.l_register),

   -- ld h, a
   [string.char(0x67)] = create_instruction_parser(
      "ld", op.h_register, op.a_register),
   -- ld h, b
   [string.char(0x60)] = create_instruction_parser(
      "ld", op.h_register, op.b_register),
   -- ld h, c
   [string.char(0x61)] = create_instruction_parser(
      "ld", op.h_register, op.c_register),
   -- ld h, d
   [string.char(0x62)] = create_instruction_parser(
      "ld", op.h_register, op.d_register),
   -- ld h, e
   [string.char(0x63)] = create_instruction_parser(
      "ld", op.h_register, op.e_register),
   -- ld h, h
   [string.char(0x64)] = create_instruction_parser(
      "ld", op.h_register, op.h_register),
   -- ld h, l
   [string.char(0x65)] = create_instruction_parser(
      "ld", op.h_register, op.l_register),

   -- ld l, a
   [string.char(0x6f)] = create_instruction_parser(
      "ld", op.l_register, op.a_register),
   -- ld l, b
   [string.char(0x68)] = create_instruction_parser(
      "ld", op.l_register, op.b_register),
   -- ld l, c
   [string.char(0x69)] = create_instruction_parser(
      "ld", op.l_register, op.c_register),
   -- ld l, d
   [string.char(0x6a)] = create_instruction_parser(
      "ld", op.l_register, op.d_register),
   -- ld l, e
   [string.char(0x6b)] = create_instruction_parser(
      "ld", op.l_register, op.e_register),
   -- ld l, h
   [string.char(0x6c)] = create_instruction_parser(
      "ld", op.l_register, op.h_register),
   -- ld l, l
   [string.char(0x6d)] = create_instruction_parser(
      "ld", op.l_register, op.l_register),

   -- "ld r8, [hl]" Instructions --

   -- ld a, [hl]
   [string.char(0x7e)] = create_instruction_parser(
      "ld", op.a_register, op.hl_register_set_reference),
   -- ld b, [hl]
   [string.char(0x46)] = create_instruction_parser(
      "ld", op.b_register, op.hl_register_set_reference),
   -- ld c, [hl]
   [string.char(0x4e)] = create_instruction_parser(
      "ld", op.c_register, op.hl_register_set_reference),
   -- ld d, [hl]
   [string.char(0x56)] = create_instruction_parser(
      "ld", op.d_register, op.hl_register_set_reference),
   -- ld e, [hl]
   [string.char(0x5e)] = create_instruction_parser(
      "ld", op.e_register, op.hl_register_set_reference),
   -- ld h, [hl]
   [string.char(0x66)] = create_instruction_parser(
      "ld", op.h_register, op.hl_register_set_reference),
   -- ld l, [hl]
   [string.char(0x6e)] = create_instruction_parser(
      "ld", op.l_register, op.hl_register_set_reference),

   -- "ld [hl], r8" Instructions --

   -- ld [hl], a
   [string.char(0x77)] = create_instruction_parser(
      "ld", op.hl_register_set_reference, op.a_register),
   -- ld [hl], b
   [string.char(0x70)] = create_instruction_parser(
      "ld", op.hl_register_set_reference, op.b_register),
   -- ld [hl], c
   [string.char(0x71)] = create_instruction_parser(
      "ld", op.hl_register_set_reference, op.c_register),
   -- ld [hl], d
   [string.char(0x72)] = create_instruction_parser(
      "ld", op.hl_register_set_reference, op.d_register),
   -- ld [hl], e
   [string.char(0x73)] = create_instruction_parser(
      "ld", op.hl_register_set_reference, op.e_register),
   -- ld [hl], h
   [string.char(0x74)] = create_instruction_parser(
      "ld", op.hl_register_set_reference, op.h_register),
   -- ld [hl], l
   [string.char(0x75)] = create_instruction_parser(
      "ld", op.hl_register_set_reference, op.l_register),

   -- "ld r8, n8" Instructions --

   -- ld a, n8
   [string.char(0x3e)] = create_byte_op_instruction_parser(
      "ld", op.a_register),
   -- ld b, n8
   [string.char(0x06)] = create_byte_op_instruction_parser(
      "ld", op.b_register),
   -- ld c, n8
   [string.char(0x0e)] = create_byte_op_instruction_parser(
      "ld", op.c_register),
   -- ld d, n8
   [string.char(0x16)] = create_byte_op_instruction_parser(
      "ld", op.d_register),
   -- ld e, n8
   [string.char(0x1e)] = create_byte_op_instruction_parser(
      "ld", op.e_register),
   -- ld h, n8
   [string.char(0x26)] = create_byte_op_instruction_parser(
      "ld", op.h_register),
   -- ld l, n8
   [string.char(0x2e)] = create_byte_op_instruction_parser(
      "ld", op.l_register),

   -- Misc. "ld"/"ldh"/"ldio" Instructions --

   -- ldio a, [$ff00+n8]
   [string.char(0xf0)] = create_byte_op_instruction_parser(
      "ldio", op.a_register, nil, true, 0xff00),
   -- ldio [$ff00+n8], a
   [string.char(0xe0)] = create_byte_op_instruction_parser(
      "ldio", nil, op.a_register, true, 0xff00),

   -- ld a, [n16]
   [string.char(0xfa)] = create_octet_op_instruction_parser(
      "ld", op.a_register, nil, true),
   -- ld [n16], a
   [string.char(0xea)] = create_octet_op_instruction_parser(
      "ld", nil, op.a_register, true),

   -- ld a, [$ff00+c]
   [string.char(0xf2)] = create_instruction_parser(
      "ld", op.a_register, op.c_register_hram_offset_reference),
   -- ld [$ff00+c], a
   [string.char(0xe2)] = create_instruction_parser(
      "ld", op.c_register_hram_offset_reference, op.a_register),

   -- ld a, [hl+]
   [string.char(0x2a)] = create_instruction_parser(
      "ld", op.a_register, op.hl_inc_register_set_reference),
   -- ld a, [hl-]
   [string.char(0x3a)] = create_instruction_parser(
      "ld", op.a_register, op.hl_dec_register_set_reference),
   -- ld a, [bc]
   [string.char(0x0a)] = create_instruction_parser(
      "ld", op.a_register, op.bc_register_set_reference),
   -- ld a, [de]
   [string.char(0x1a)] = create_instruction_parser(
      "ld", op.a_register, op.de_register_set_reference),

   -- ld hl, n8
   [string.char(0x21)] = create_octet_op_instruction_parser(
      "ld", op.hl_register_set),
   -- ld bc, n8
   [string.char(0x01)] = create_octet_op_instruction_parser(
      "ld", op.bc_register_set),
   -- ld de, n8
   [string.char(0x11)] = create_octet_op_instruction_parser(
      "ld", op.de_register_set),

   -- ld [hl+], a
   [string.char(0x22)] = create_instruction_parser(
      "ld", op.hl_inc_register_set_reference, op.a_register),
   -- ld [hl-], a
   [string.char(0x32)] = create_instruction_parser(
      "ld", op.hl_dec_register_set_reference, op.a_register),

   -- ld [hl], n8
   [string.char(0x36)] = create_byte_op_instruction_parser(
      "ld", op.hl_register_set_reference),

   -- ld [bc], a
   [string.char(0x02)] = create_instruction_parser(
      "ld", op.bc_register_set_reference, op.a_register),
   -- ld [de], a
   [string.char(0x12)] = create_instruction_parser(
      "ld", op.de_register_set_reference, op.a_register),

   -- Arithmetic Instructions --

   -- add a, a
   [string.char(0x87)] = create_instruction_parser(
      "add", op.a_register, op.a_register),
   -- add a, b
   [string.char(0x80)] = create_instruction_parser(
      "add", op.a_register, op.b_register),
   -- add a, c
   [string.char(0x81)] = create_instruction_parser(
      "add", op.a_register, op.c_register),
   -- add a, d
   [string.char(0x82)] = create_instruction_parser(
      "add", op.a_register, op.d_register),
   -- add a, e
   [string.char(0x83)] = create_instruction_parser(
      "add", op.a_register, op.e_register),
   -- add a, h
   [string.char(0x84)] = create_instruction_parser(
      "add", op.a_register, op.h_register),
   -- add a, l
   [string.char(0x85)] = create_instruction_parser(
      "add", op.a_register, op.l_register),

   -- add a, [hl]
   [string.char(0x86)] = create_instruction_parser(
      "add", op.a_register, op.hl_register_set_reference),

   -- add a, n8
   [string.char(0xc6)] = create_byte_op_instruction_parser(
      "add", op.a_register),

   -- adc a, a
   [string.char(0x8f)] = create_instruction_parser(
      "adc", op.a_register, op.a_register),
   -- adc a, b
   [string.char(0x88)] = create_instruction_parser(
      "adc", op.a_register, op.b_register),
   -- adc a, c
   [string.char(0x89)] = create_instruction_parser(
      "adc", op.a_register, op.c_register),
   -- adc a, d
   [string.char(0x8a)] = create_instruction_parser(
      "adc", op.a_register, op.d_register),
   -- adc a, e
   [string.char(0x8b)] = create_instruction_parser(
      "adc", op.a_register, op.e_register),
   -- adc a, h
   [string.char(0x8c)] = create_instruction_parser(
      "adc", op.a_register, op.h_register),
   -- adc a, l
   [string.char(0x8d)] = create_instruction_parser(
      "adc", op.a_register, op.l_register),

   -- adc a, [hl]
   [string.char(0x8e)] = create_instruction_parser(
      "adc", op.a_register, op.hl_register_set_reference),

   -- adc a, n8
   [string.char(0xce)] = create_byte_op_instruction_parser(
      "adc", op.a_register),

   -- sub a, a
   [string.char(0x97)] = create_instruction_parser(
      "sub", op.a_register, op.a_register),
   -- sub a, b
   [string.char(0x90)] = create_instruction_parser(
      "sub", op.a_register, op.b_register),
   -- sub a, c
   [string.char(0x91)] = create_instruction_parser(
      "sub", op.a_register, op.c_register),
   -- sub a, d
   [string.char(0x92)] = create_instruction_parser(
      "sub", op.a_register, op.d_register),
   -- sub a, e
   [string.char(0x93)] = create_instruction_parser(
      "sub", op.a_register, op.e_register),
   -- sub a, h
   [string.char(0x94)] = create_instruction_parser(
      "sub", op.a_register, op.h_register),
   -- sub a, l
   [string.char(0x95)] = create_instruction_parser(
      "sub", op.a_register, op.l_register),

   -- sub a, [hl]
   [string.char(0x96)] = create_instruction_parser(
      "sub", op.a_register, op.hl_register_set_reference),

   -- sub a, n8
   [string.char(0xd6)] = create_byte_op_instruction_parser(
      "sub", op.a_register),

   -- sbc a, a
   [string.char(0x9f)] = create_instruction_parser(
      "sbc", op.a_register, op.a_register),
   -- sbc a, b
   [string.char(0x98)] = create_instruction_parser(
      "sbc", op.a_register, op.b_register),
   -- sbc a, c
   [string.char(0x99)] = create_instruction_parser(
      "sbc", op.a_register, op.c_register),
   -- sbc a, d
   [string.char(0x9a)] = create_instruction_parser(
      "sbc", op.a_register, op.d_register),
   -- sbc a, e
   [string.char(0x9b)] = create_instruction_parser(
      "sbc", op.a_register, op.e_register),
   -- sbc a, h
   [string.char(0x9c)] = create_instruction_parser(
      "sbc", op.a_register, op.h_register),
   -- sbc a, l
   [string.char(0x9d)] = create_instruction_parser(
      "sbc", op.a_register, op.l_register),

   -- sbc a, [hl]
   [string.char(0x9e)] = create_instruction_parser(
      "sbc", op.a_register, op.hl_register_set_reference),

   -- sbc a, n8
   [string.char(0xde)] = create_byte_op_instruction_parser(
      "sbc", op.a_register),

   -- add hl, hl
   [string.char(0x29)] = create_instruction_parser(
      "sbc", op.hl_register_set, op.hl_register_set),
   -- add hl, bc
   [string.char(0x09)] = create_instruction_parser(
      "sbc", op.hl_register_set, op.bc_register_set),
   -- add hl, de
   [string.char(0x19)] = create_instruction_parser(
      "sbc", op.hl_register_set, op.de_register_set),

   -- daa
   [string.char(0x27)] = create_instruction_parser("daa"),
   -- scf
   [string.char(0x37)] = create_instruction_parser("scf"),

   -- Logical Instructions --

   -- and a, a
   [string.char(0xa7)] = create_instruction_parser(
      "and", op.a_register, op.a_register),
   -- and a, b
   [string.char(0xa0)] = create_instruction_parser(
      "and", op.a_register, op.b_register),
   -- and a, c
   [string.char(0xa1)] = create_instruction_parser(
      "and", op.a_register, op.c_register),
   -- and a, d
   [string.char(0xa2)] = create_instruction_parser(
      "and", op.a_register, op.d_register),
   -- and a, e
   [string.char(0xa3)] = create_instruction_parser(
      "and", op.a_register, op.e_register),
   -- and a, h
   [string.char(0xa4)] = create_instruction_parser(
      "and", op.a_register, op.h_register),
   -- and a, l
   [string.char(0xa5)] = create_instruction_parser(
      "and", op.a_register, op.l_register),

   -- and a, [hl]
   [string.char(0xa6)] = create_instruction_parser(
      "and", op.a_register, op.hl_register_set_reference),

   -- and a, n8
   [string.char(0xe6)] = create_byte_op_instruction_parser(
      "and", op.a_register),

   -- xor a, a
   [string.char(0xaf)] = create_instruction_parser(
      "xor", op.a_register, op.a_register),
   -- xor a, b
   [string.char(0xa8)] = create_instruction_parser(
      "xor", op.a_register, op.b_register),
   -- xor a, c
   [string.char(0xa9)] = create_instruction_parser(
      "xor", op.a_register, op.c_register),
   -- xor a, d
   [string.char(0xaa)] = create_instruction_parser(
      "xor", op.a_register, op.d_register),
   -- xor a, e
   [string.char(0xab)] = create_instruction_parser(
      "xor", op.a_register, op.e_register),
   -- xor a, h
   [string.char(0xac)] = create_instruction_parser(
      "xor", op.a_register, op.h_register),
   -- xor a, l
   [string.char(0xad)] = create_instruction_parser(
      "xor", op.a_register, op.l_register),

   -- xor a, [hl]
   [string.char(0xae)] = create_instruction_parser(
      "xor", op.a_register, op.hl_register_set_reference),

   -- xor a, n8
   [string.char(0xee)] = create_byte_op_instruction_parser(
      "xor", op.a_register),

   -- or a, a
   [string.char(0xb7)] = create_instruction_parser(
      "or", op.a_register, op.a_register),
   -- or a, b
   [string.char(0xb0)] = create_instruction_parser(
      "or", op.a_register, op.b_register),
   -- or a, c
   [string.char(0xb1)] = create_instruction_parser(
      "or", op.a_register, op.c_register),
   -- or a, d
   [string.char(0xb2)] = create_instruction_parser(
      "or", op.a_register, op.d_register),
   -- or a, e
   [string.char(0xb3)] = create_instruction_parser(
      "or", op.a_register, op.e_register),
   -- or a, h
   [string.char(0xb4)] = create_instruction_parser(
      "or", op.a_register, op.h_register),
   -- or a, l
   [string.char(0xb5)] = create_instruction_parser(
      "or", op.a_register, op.l_register),

   -- or a, [hl]
   [string.char(0xb6)] = create_instruction_parser(
      "or", op.a_register, op.hl_register_set_reference),

   -- or a, n8
   [string.char(0xf6)] = create_byte_op_instruction_parser(
      "or", op.a_register),

   -- cp a, a
   [string.char(0xbf)] = create_instruction_parser(
      "cp", op.a_register, op.a_register),
   -- cp a, b
   [string.char(0xb8)] = create_instruction_parser(
      "cp", op.a_register, op.b_register),
   -- cp a, c
   [string.char(0xb9)] = create_instruction_parser(
      "cp", op.a_register, op.c_register),
   -- cp a, d
   [string.char(0xba)] = create_instruction_parser(
      "cp", op.a_register, op.d_register),
   -- cp a, e
   [string.char(0xbb)] = create_instruction_parser(
      "cp", op.a_register, op.e_register),
   -- cp a, h
   [string.char(0xbc)] = create_instruction_parser(
      "cp", op.a_register, op.h_register),
   -- cp a, l
   [string.char(0xbd)] = create_instruction_parser(
      "cp", op.a_register, op.l_register),

   -- cp a, [hl]
   [string.char(0xbe)] = create_instruction_parser(
      "cp", op.a_register, op.hl_register_set_reference),

   -- cp a, n8
   [string.char(0xfe)] = create_byte_op_instruction_parser(
      "cp", op.a_register),

   -- cpl
   [string.char(0x2f)] = create_instruction_parser("cpl"),
   -- ccf
   [string.char(0x3f)] = create_instruction_parser("ccf"),

   -- Shift/Rotation Instructions --

   -- rlca
   [string.char(0x07)] = create_instruction_parser("rlca"),
   -- rla
   [string.char(0x17)] = create_instruction_parser("rla"),

   -- rrca
   [string.char(0x0f)] = create_instruction_parser("rrca"),
   -- rra
   [string.char(0x1f)] = create_instruction_parser("rra"),

   -- Increment/Decrement Instructions

   -- inc a
   [string.char(0x3c)] = create_instruction_parser(
      "inc", op.a_register),
   -- inc b
   [string.char(0x04)] = create_instruction_parser(
      "inc", op.b_register),
   -- inc c
   [string.char(0x0c)] = create_instruction_parser(
      "inc", op.c_register),
   -- inc d
   [string.char(0x14)] = create_instruction_parser(
      "inc", op.d_register),
   -- inc e
   [string.char(0x1c)] = create_instruction_parser(
      "inc", op.e_register),
   -- inc h
   [string.char(0x24)] = create_instruction_parser(
      "inc", op.h_register),
   -- inc l
   [string.char(0x2c)] = create_instruction_parser(
      "inc", op.l_register),

   -- inc hl
   [string.char(0x23)] = create_instruction_parser(
      "inc", op.hl_register_set),
   -- inc bc
   [string.char(0x03)] = create_instruction_parser(
      "inc", op.bc_register_set),
   -- inc de
   [string.char(0x13)] = create_instruction_parser(
      "inc", op.de_register_set),

   -- inc [hl]
   [string.char(0x34)] = create_instruction_parser(
      "inc", op.hl_register_set_reference),

   -- dec a
   [string.char(0x3d)] = create_instruction_parser(
      "dec", op.a_register),
   -- dec b
   [string.char(0x05)] = create_instruction_parser(
      "dec", op.b_register),
   -- dec c
   [string.char(0x0d)] = create_instruction_parser(
      "dec", op.c_register),
   -- dec d
   [string.char(0x15)] = create_instruction_parser(
      "dec", op.d_register),
   -- dec e
   [string.char(0x1d)] = create_instruction_parser(
      "dec", op.e_register),
   -- dec h
   [string.char(0x25)] = create_instruction_parser(
      "dec", op.h_register),
   -- dec l
   [string.char(0x2d)] = create_instruction_parser(
      "dec", op.l_register),

   -- dec hl
   [string.char(0x2b)] = create_instruction_parser(
      "dec", op.hl_register_set),
   -- dec bc
   [string.char(0x0b)] = create_instruction_parser(
      "dec", op.bc_register_set),
   -- dec de
   [string.char(0x1b)] = create_instruction_parser(
      "dec", op.de_register_set),

   -- dec [hl]
   [string.char(0x35)] = create_instruction_parser(
      "dec", op.hl_register_set_reference),

   -- Stack Instructions --

   -- push af
   [string.char(0xf5)] = create_instruction_parser(
      "push", op.af_register_set),
   -- push bc
   [string.char(0xc5)] = create_instruction_parser(
      "push", op.bc_register_set),
   -- push de
   [string.char(0xd5)] = create_instruction_parser(
      "push", op.de_register_set),
   -- push hl
   [string.char(0xe5)] = create_instruction_parser(
      "push", op.hl_register_set),

   -- pop af
   [string.char(0xf1)] = create_instruction_parser(
      "pop", op.af_register_set),
   -- pop bc
   [string.char(0xc1)] = create_instruction_parser(
      "pop", op.bc_register_set),
   -- pop de
   [string.char(0xd1)] = create_instruction_parser(
      "pop", op.de_register_set),
   -- pop hl
   [string.char(0xe1)] = create_instruction_parser(
      "pop", op.hl_register_set),

   -- inc sp
   [string.char(0x33)] = create_instruction_parser(
      "inc", op.sp_register),
   -- dec sp
   [string.char(0x3b)] = create_instruction_parser(
      "dec", op.sp_register),

   -- ld sp, hl
   [string.char(0xf9)] = create_instruction_parser(
      "ld", op.sp_register, op.hl_register_set),
   -- add hl, sp
   [string.char(0x39)] = create_instruction_parser(
      "add", op.hl_register_set, op.sp_register),

   -- ld sp, n16
   [string.char(0x31)] = create_octet_op_instruction_parser(
      "ld", op.sp_register),
   -- add sp, e8
   [string.char(0xe8)] = create_byte_op_instruction_parser(
      "add", op.sp_register),
   -- ld hl, sp+e8
   [string.char(0xf8)] = create_sp_offset_op_instruction_parser(
      "ld", op.hl_register_set),
   -- ld [n16], sp
   [string.char(0x08)] = create_octet_op_instruction_parser(
      "ld", nil, op.sp_register, true),

   -- Jump/Call Instructions --

   -- call n16
   [string.char(0xcd)] = create_octet_op_instruction_parser("call"),
   -- call c, n16
   [string.char(0xdc)] = create_octet_op_instruction_parser(
      "call", op.c_condition),
   -- call z, n16
   [string.char(0xcc)] = create_octet_op_instruction_parser(
      "call", op.z_condition),
   -- call nc, n16
   [string.char(0xd4)] = create_octet_op_instruction_parser(
      "call", op.nc_condition),
   -- call nz, n16
   [string.char(0xc4)] = create_octet_op_instruction_parser(
      "call", op.nz_condition),

   -- jp n16
   [string.char(0xc3)] = create_octet_op_instruction_parser("jp"),
   -- jp c, n16
   [string.char(0xda)] = create_octet_op_instruction_parser(
      "jp", op.c_condition),
   -- jp z, n16
   [string.char(0xca)] = create_octet_op_instruction_parser(
      "jp", op.z_condition),
   -- jp nc, n16
   [string.char(0xd2)] = create_octet_op_instruction_parser(
      "jp", op.nc_condition),
   -- jp nz, n16
   [string.char(0xc2)] = create_octet_op_instruction_parser(
      "jp", op.nz_condition),

   -- jr e8
   [string.char(0x18)] = create_byte_op_instruction_parser("jr"),
   -- jr c, e8
   [string.char(0x38)] = create_byte_op_instruction_parser(
      "jr", op.c_condition),
   -- jr z, e8
   [string.char(0x28)] = create_byte_op_instruction_parser(
      "jr", op.z_condition),
   -- jr nc, e8
   [string.char(0x30)] = create_byte_op_instruction_parser(
      "jr", op.nc_condition),
   -- jr nz, e8
   [string.char(0x20)] = create_byte_op_instruction_parser(
      "jr", op.nz_condition),

   -- jp hl
   [string.char(0xe9)] = create_instruction_parser(
      "jp", op.hl_register_set_reference),

   -- rst 00h
   [string.char(0xc7)] = create_instruction_parser(
      "rst", op.vector_00h),
   -- rst 08h
   [string.char(0xcf)] = create_instruction_parser(
      "rst", op.vector_08h),
   -- rst 10h
   [string.char(0xd7)] = create_instruction_parser(
      "rst", op.vector_10h),
   -- rst 18h
   [string.char(0xdf)] = create_instruction_parser(
      "rst", op.vector_18h),
   -- rst 20h
   [string.char(0xe7)] = create_instruction_parser(
      "rst", op.vector_20h),
   -- rst 28h
   [string.char(0xef)] = create_instruction_parser(
      "rst", op.vector_28h),
   -- rst 30h
   [string.char(0xf7)] = create_instruction_parser(
      "rst", op.vector_30h),
   -- rst 38h
   [string.char(0xff)] = create_instruction_parser(
      "rst", op.vector_38h),

   -- ret
   [string.char(0xc9)] = create_instruction_parser("ret"),
   -- reti
   [string.char(0xd9)] = create_instruction_parser("reti"),
   -- ret c
   [string.char(0xd8)] = create_instruction_parser(
      "ret", op.c_condition),
   -- ret z
   [string.char(0xc8)] = create_instruction_parser(
      "ret", op.z_condition),
   -- ret nc
   [string.char(0xd0)] = create_instruction_parser(
      "ret", op.nc_condition),
   -- ret nz
   [string.char(0xc0)] = create_instruction_parser(
      "ret", op.nz_condition)
}

local extended_instructions = {
   [string.char(0x10)] = {
      -- stop
      [string.char(0x00)] = create_extended_instruction_parser("stop", create_dynamic_byte_operand(0))
   },
   [string.char(0xcb)] = {
      -- "rlc" Instructions --

      -- rlc a
      [string.char(0x07)] = create_extended_instruction_parser(
         "rlc", op.a_register),
      -- rlc b
      [string.char(0x00)] = create_extended_instruction_parser(
         "rlc", op.b_register),
      -- rlc c
      [string.char(0x01)] = create_extended_instruction_parser(
         "rlc", op.c_register),
      -- rlc d
      [string.char(0x02)] = create_extended_instruction_parser(
         "rlc", op.d_register),
      -- rlc e
      [string.char(0x03)] = create_extended_instruction_parser(
         "rlc", op.e_register),
      -- rlc h
      [string.char(0x04)] = create_extended_instruction_parser(
         "rlc", op.h_register),
      -- rlc l
      [string.char(0x05)] = create_extended_instruction_parser(
         "rlc", op.l_register),
      -- rlc [hl]
      [string.char(0x06)] = create_extended_instruction_parser(
         "rlc", op.hl_register_set_reference),

      -- "rrc" Instructions --

      -- rrc a
      [string.char(0x0f)] = create_extended_instruction_parser(
         "rrc", op.a_register),
      -- rrc b
      [string.char(0x08)] = create_extended_instruction_parser(
         "rrc", op.b_register),
      -- rrc c
      [string.char(0x09)] = create_extended_instruction_parser(
         "rrc", op.c_register),
      -- rrc d
      [string.char(0x0a)] = create_extended_instruction_parser(
         "rrc", op.d_register),
      -- rrc e
      [string.char(0x0b)] = create_extended_instruction_parser(
         "rrc", op.e_register),
      -- rrc h
      [string.char(0x0c)] = create_extended_instruction_parser(
         "rrc", op.h_register),
      -- rrc l
      [string.char(0x0d)] = create_extended_instruction_parser(
         "rrc", op.l_register),
      -- rrc [hl]
      [string.char(0x0e)] = create_extended_instruction_parser(
         "rrc", op.hl_register_set_reference),

      -- "rl" Instructions --

      -- rl a
      [string.char(0x17)] = create_extended_instruction_parser(
         "rl", op.a_register),
      -- rl b
      [string.char(0x10)] = create_extended_instruction_parser(
         "rl", op.b_register),
      -- rl c
      [string.char(0x11)] = create_extended_instruction_parser(
         "rl", op.c_register),
      -- rl d
      [string.char(0x12)] = create_extended_instruction_parser(
         "rl", op.d_register),
      -- rl e
      [string.char(0x13)] = create_extended_instruction_parser(
         "rl", op.e_register),
      -- rl h
      [string.char(0x14)] = create_extended_instruction_parser(
         "rl", op.h_register),
      -- rl l
      [string.char(0x15)] = create_extended_instruction_parser(
         "rl", op.l_register),
      -- rl [hl]
      [string.char(0x16)] = create_extended_instruction_parser(
         "rl", op.hl_register_set_reference),

      -- "rr" Instructions --

      -- rr a
      [string.char(0x1f)] = create_extended_instruction_parser(
         "rr", op.a_register),
      -- rr b
      [string.char(0x18)] = create_extended_instruction_parser(
         "rr", op.b_register),
      -- rr c
      [string.char(0x19)] = create_extended_instruction_parser(
         "rr", op.c_register),
      -- rr d
      [string.char(0x1a)] = create_extended_instruction_parser(
         "rr", op.d_register),
      -- rr e
      [string.char(0x1b)] = create_extended_instruction_parser(
         "rr", op.e_register),
      -- rr h
      [string.char(0x1c)] = create_extended_instruction_parser(
         "rr", op.h_register),
      -- rr l
      [string.char(0x1d)] = create_extended_instruction_parser(
         "rr", op.l_register),
      -- rr [hl]
      [string.char(0x1e)] = create_extended_instruction_parser(
         "rr", op.hl_register_set_reference),

      -- "sla" Instructions --

      -- sla a
      [string.char(0x27)] = create_extended_instruction_parser(
         "sla", op.a_register),
      -- sla b
      [string.char(0x20)] = create_extended_instruction_parser(
         "sla", op.b_register),
      -- sla c
      [string.char(0x21)] = create_extended_instruction_parser(
         "sla", op.c_register),
      -- sla d
      [string.char(0x22)] = create_extended_instruction_parser(
         "sla", op.d_register),
      -- sla e
      [string.char(0x23)] = create_extended_instruction_parser(
         "sla", op.e_register),
      -- sla h
      [string.char(0x24)] = create_extended_instruction_parser(
         "sla", op.h_register),
      -- sla l
      [string.char(0x25)] = create_extended_instruction_parser(
         "sla", op.l_register),
      -- sla [hl]
      [string.char(0x26)] = create_extended_instruction_parser(
         "sla", op.hl_register_set_reference),

      -- "sra" Instructions --

      -- sra a
      [string.char(0x2f)] = create_extended_instruction_parser(
         "sra", op.a_register),
      -- sra b
      [string.char(0x28)] = create_extended_instruction_parser(
         "sra", op.b_register),
      -- sra c
      [string.char(0x29)] = create_extended_instruction_parser(
         "sra", op.c_register),
      -- sra d
      [string.char(0x2a)] = create_extended_instruction_parser(
         "sra", op.d_register),
      -- sra e
      [string.char(0x2b)] = create_extended_instruction_parser(
         "sra", op.e_register),
      -- sra h
      [string.char(0x2c)] = create_extended_instruction_parser(
         "sra", op.h_register),
      -- sra l
      [string.char(0x2d)] = create_extended_instruction_parser(
         "sra", op.l_register),
      -- sra [hl]
      [string.char(0x2e)] = create_extended_instruction_parser(
         "sra", op.hl_register_set_reference),

      -- "swap" Instructions --

      -- swap a
      [string.char(0x37)] = create_extended_instruction_parser(
         "swap", op.a_register),
      -- swap b
      [string.char(0x30)] = create_extended_instruction_parser(
         "swap", op.b_register),
      -- swap c
      [string.char(0x31)] = create_extended_instruction_parser(
         "swap", op.c_register),
      -- swap d
      [string.char(0x32)] = create_extended_instruction_parser(
         "swap", op.d_register),
      -- swap e
      [string.char(0x33)] = create_extended_instruction_parser(
         "swap", op.e_register),
      -- swap h
      [string.char(0x34)] = create_extended_instruction_parser(
         "swap", op.h_register),
      -- swap l
      [string.char(0x35)] = create_extended_instruction_parser(
         "swap", op.l_register),
      -- swap [hl]
      [string.char(0x36)] = create_extended_instruction_parser(
         "swap", op.hl_register_set_reference),

      -- "srl" Instructions --

      -- srl a
      [string.char(0x3f)] = create_extended_instruction_parser(
         "srl", op.a_register),
      -- srl b
      [string.char(0x38)] = create_extended_instruction_parser(
         "srl", op.b_register),
      -- srl c
      [string.char(0x39)] = create_extended_instruction_parser(
         "srl", op.c_register),
      -- srl d
      [string.char(0x3a)] = create_extended_instruction_parser(
         "srl", op.d_register),
      -- srl e
      [string.char(0x3b)] = create_extended_instruction_parser(
         "srl", op.e_register),
      -- srl h
      [string.char(0x3c)] = create_extended_instruction_parser(
         "srl", op.h_register),
      -- srl l
      [string.char(0x3d)] = create_extended_instruction_parser(
         "srl", op.l_register),
      -- srl [hl]
      [string.char(0x3e)] = create_extended_instruction_parser(
         "srl", op.hl_register_set_reference),

      -- "bit" Instructions --

      -- bit 0, a
      [string.char(0x47)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(0), op.a_register),
      -- bit 0, b
      [string.char(0x40)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(0), op.b_register),
      -- bit 0, c
      [string.char(0x41)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(0), op.c_register),
      -- bit 0, d
      [string.char(0x42)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(0), op.d_register),
      -- bit 0, e
      [string.char(0x43)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(0), op.e_register),
      -- bit 0, h
      [string.char(0x44)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(0), op.h_register),
      -- bit 0, l
      [string.char(0x45)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(0), op.l_register),
      -- bit 0, [hl]
      [string.char(0x46)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(0), op.hl_register_set_reference),

      -- bit 1, a
      [string.char(0x4f)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(1), op.a_register),
      -- bit 1, b
      [string.char(0x48)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(1), op.b_register),
      -- bit 1, c
      [string.char(0x49)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(1), op.c_register),
      -- bit 1, d
      [string.char(0x4a)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(1), op.d_register),
      -- bit 1, e
      [string.char(0x4b)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(1), op.e_register),
      -- bit 1, h
      [string.char(0x4c)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(1), op.h_register),
      -- bit 1, l
      [string.char(0x4d)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(1), op.l_register),
      -- bit 1, [hl]
      [string.char(0x4e)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(1), op.hl_register_set_reference),

      -- bit 2, a
      [string.char(0x57)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(2), op.a_register),
      -- bit 2, b
      [string.char(0x50)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(2), op.b_register),
      -- bit 2, c
      [string.char(0x51)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(2), op.c_register),
      -- bit 2, d
      [string.char(0x52)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(2), op.d_register),
      -- bit 2, e
      [string.char(0x53)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(2), op.e_register),
      -- bit 2, h
      [string.char(0x54)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(2), op.h_register),
      -- bit 2, l
      [string.char(0x55)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(2), op.l_register),
      -- bit 2, [hl]
      [string.char(0x56)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(2), op.hl_register_set_reference),

      -- bit 3, a
      [string.char(0x5f)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(3), op.a_register),
      -- bit 3, b
      [string.char(0x58)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(3), op.b_register),
      -- bit 3, c
      [string.char(0x59)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(3), op.c_register),
      -- bit 3, d
      [string.char(0x5a)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(3), op.d_register),
      -- bit 3, e
      [string.char(0x5b)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(3), op.e_register),
      -- bit 3, h
      [string.char(0x5c)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(3), op.h_register),
      -- bit 3, l
      [string.char(0x5d)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(3), op.l_register),
      -- bit 3, [hl]
      [string.char(0x5e)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(3), op.hl_register_set_reference),

      -- bit 4, a
      [string.char(0x67)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(4), op.a_register),
      -- bit 4, b
      [string.char(0x60)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(4), op.b_register),
      -- bit 4, c
      [string.char(0x61)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(4), op.c_register),
      -- bit 4, d
      [string.char(0x62)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(4), op.d_register),
      -- bit 4, e
      [string.char(0x63)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(4), op.e_register),
      -- bit 4, h
      [string.char(0x64)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(4), op.h_register),
      -- bit 4, l
      [string.char(0x65)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(4), op.l_register),
      -- bit 4, [hl]
      [string.char(0x66)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(4), op.hl_register_set_reference),

      -- bit 5, a
      [string.char(0x6f)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(5), op.a_register),
      -- bit 5, b
      [string.char(0x68)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(5), op.b_register),
      -- bit 5, c
      [string.char(0x69)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(5), op.c_register),
      -- bit 5, d
      [string.char(0x6a)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(5), op.d_register),
      -- bit 5, e
      [string.char(0x6b)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(5), op.e_register),
      -- bit 5, h
      [string.char(0x6c)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(5), op.h_register),
      -- bit 5, l
      [string.char(0x6d)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(5), op.l_register),
      -- bit 5, [hl]
      [string.char(0x6e)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(5), op.hl_register_set_reference),

      -- bit 6, a
      [string.char(0x77)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(6), op.a_register),
      -- bit 6, b
      [string.char(0x70)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(6), op.b_register),
      -- bit 6, c
      [string.char(0x71)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(6), op.c_register),
      -- bit 6, d
      [string.char(0x72)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(6), op.d_register),
      -- bit 6, e
      [string.char(0x73)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(6), op.e_register),
      -- bit 6, h
      [string.char(0x74)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(6), op.h_register),
      -- bit 6, l
      [string.char(0x75)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(6), op.l_register),
      -- bit 6, [hl]
      [string.char(0x76)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(6), op.hl_register_set_reference),

      -- bit 7, a
      [string.char(0x7f)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(7), op.a_register),
      -- bit 7, b
      [string.char(0x78)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(7), op.b_register),
      -- bit 7, c
      [string.char(0x79)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(7), op.c_register),
      -- bit 7, d
      [string.char(0x7a)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(7), op.d_register),
      -- bit 7, e
      [string.char(0x7b)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(7), op.e_register),
      -- bit 7, h
      [string.char(0x7c)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(7), op.h_register),
      -- bit 7, l
      [string.char(0x7d)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(7), op.l_register),
      -- bit 7, [hl]
      [string.char(0x7e)] = create_extended_instruction_parser(
         "bit", create_dynamic_byte_operand(7), op.hl_register_set_reference),

      -- "res" Instructions --

      -- res 0, a
      [string.char(0x87)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(0), op.a_register),
      -- res 0, b
      [string.char(0x80)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(0), op.b_register),
      -- res 0, c
      [string.char(0x81)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(0), op.c_register),
      -- res 0, d
      [string.char(0x82)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(0), op.d_register),
      -- res 0, e
      [string.char(0x83)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(0), op.e_register),
      -- res 0, h
      [string.char(0x84)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(0), op.h_register),
      -- res 0, l
      [string.char(0x85)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(0), op.l_register),
      -- res 0, [hl]
      [string.char(0x86)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(0), op.hl_register_set_reference),

      -- res 1, a
      [string.char(0x8f)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(1), op.a_register),
      -- res 1, b
      [string.char(0x88)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(1), op.b_register),
      -- res 1, c
      [string.char(0x89)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(1), op.c_register),
      -- res 1, d
      [string.char(0x8a)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(1), op.d_register),
      -- res 1, e
      [string.char(0x8b)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(1), op.e_register),
      -- res 1, h
      [string.char(0x8c)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(1), op.h_register),
      -- res 1, l
      [string.char(0x8d)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(1), op.l_register),
      -- res 1, [hl]
      [string.char(0x8e)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(1), op.hl_register_set_reference),

      -- res 2, a
      [string.char(0x97)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(2), op.a_register),
      -- res 2, b
      [string.char(0x90)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(2), op.b_register),
      -- res 2, c
      [string.char(0x91)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(2), op.c_register),
      -- res 2, d
      [string.char(0x92)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(2), op.d_register),
      -- res 2, e
      [string.char(0x93)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(2), op.e_register),
      -- res 2, h
      [string.char(0x94)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(2), op.h_register),
      -- res 2, l
      [string.char(0x95)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(2), op.l_register),
      -- res 2, [hl]
      [string.char(0x96)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(2), op.hl_register_set_reference),

      -- res 3, a
      [string.char(0x9f)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(3), op.a_register),
      -- res 3, b
      [string.char(0x98)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(3), op.b_register),
      -- res 3, c
      [string.char(0x99)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(3), op.c_register),
      -- res 3, d
      [string.char(0x9a)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(3), op.d_register),
      -- res 3, e
      [string.char(0x9b)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(3), op.e_register),
      -- res 3, h
      [string.char(0x9c)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(3), op.h_register),
      -- res 3, l
      [string.char(0x9d)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(3), op.l_register),
      -- res 3, [hl]
      [string.char(0x9e)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(3), op.hl_register_set_reference),

      -- res 4, a
      [string.char(0xa7)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(4), op.a_register),
      -- res 4, b
      [string.char(0xa0)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(4), op.b_register),
      -- res 4, c
      [string.char(0xa1)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(4), op.c_register),
      -- res 4, d
      [string.char(0xa2)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(4), op.d_register),
      -- res 4, e
      [string.char(0xa3)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(4), op.e_register),
      -- res 4, h
      [string.char(0xa4)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(4), op.h_register),
      -- res 4, l
      [string.char(0xa5)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(4), op.l_register),
      -- res 4, [hl]
      [string.char(0xa6)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(4), op.hl_register_set_reference),

      -- res 5, a
      [string.char(0xaf)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(5), op.a_register),
      -- res 5, b
      [string.char(0xa8)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(5), op.b_register),
      -- res 5, c
      [string.char(0xa9)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(5), op.c_register),
      -- res 5, d
      [string.char(0xaa)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(5), op.d_register),
      -- res 5, e
      [string.char(0xab)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(5), op.e_register),
      -- res 5, h
      [string.char(0xac)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(5), op.h_register),
      -- res 5, l
      [string.char(0xad)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(5), op.l_register),
      -- res 5, [hl]
      [string.char(0xae)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(5), op.hl_register_set_reference),

      -- res 6, a
      [string.char(0xb7)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(6), op.a_register),
      -- res 6, b
      [string.char(0xb0)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(6), op.b_register),
      -- res 6, c
      [string.char(0xb1)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(6), op.c_register),
      -- res 6, d
      [string.char(0xb2)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(6), op.d_register),
      -- res 6, e
      [string.char(0xb3)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(6), op.e_register),
      -- res 6, h
      [string.char(0xb4)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(6), op.h_register),
      -- res 6, l
      [string.char(0xb5)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(6), op.l_register),
      -- res 6, [hl]
      [string.char(0xb6)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(6), op.hl_register_set_reference),

      -- res 7, a
      [string.char(0xbf)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(7), op.a_register),
      -- res 7, b
      [string.char(0xb8)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(7), op.b_register),
      -- res 7, c
      [string.char(0xb9)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(7), op.c_register),
      -- res 7, d
      [string.char(0xba)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(7), op.d_register),
      -- res 7, e
      [string.char(0xbb)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(7), op.e_register),
      -- res 7, h
      [string.char(0xbc)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(7), op.h_register),
      -- res 7, l
      [string.char(0xbd)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(7), op.l_register),
      -- res 7, [hl]
      [string.char(0xbe)] = create_extended_instruction_parser(
         "res", create_dynamic_byte_operand(7), op.hl_register_set_reference),

      -- "set" Instructions --

      -- set 0, a
      [string.char(0xc7)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(0), op.a_register),
      -- set 0, b
      [string.char(0xc0)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(0), op.b_register),
      -- set 0, c
      [string.char(0xc1)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(0), op.c_register),
      -- set 0, d
      [string.char(0xc2)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(0), op.d_register),
      -- set 0, e
      [string.char(0xc3)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(0), op.e_register),
      -- set 0, h
      [string.char(0xc4)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(0), op.h_register),
      -- set 0, l
      [string.char(0xc5)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(0), op.l_register),
      -- set 0, [hl]
      [string.char(0xc6)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(0), op.hl_register_set_reference),

      -- set 1, a
      [string.char(0xcf)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(1), op.a_register),
      -- set 1, b
      [string.char(0xc8)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(1), op.b_register),
      -- set 1, c
      [string.char(0xc9)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(1), op.c_register),
      -- set 1, d
      [string.char(0xca)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(1), op.d_register),
      -- set 1, e
      [string.char(0xcb)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(1), op.e_register),
      -- set 1, h
      [string.char(0xcc)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(1), op.h_register),
      -- set 1, l
      [string.char(0xcd)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(1), op.l_register),
      -- set 1, [hl]
      [string.char(0xce)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(1), op.hl_register_set_reference),

      -- set 2, a
      [string.char(0xd7)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(2), op.a_register),
      -- set 2, b
      [string.char(0xd0)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(2), op.b_register),
      -- set 2, c
      [string.char(0xd1)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(2), op.c_register),
      -- set 2, d
      [string.char(0xd2)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(2), op.d_register),
      -- set 2, e
      [string.char(0xd3)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(2), op.e_register),
      -- set 2, h
      [string.char(0xd4)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(2), op.h_register),
      -- set 2, l
      [string.char(0xd5)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(2), op.l_register),
      -- set 2, [hl]
      [string.char(0xd6)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(2), op.hl_register_set_reference),

      -- set 3, a
      [string.char(0xdf)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(3), op.a_register),
      -- set 3, b
      [string.char(0xd8)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(3), op.b_register),
      -- set 3, c
      [string.char(0xd9)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(3), op.c_register),
      -- set 3, d
      [string.char(0xda)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(3), op.d_register),
      -- set 3, e
      [string.char(0xdb)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(3), op.e_register),
      -- set 3, h
      [string.char(0xdc)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(3), op.h_register),
      -- set 3, l
      [string.char(0xdd)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(3), op.l_register),
      -- set 3, [hl]
      [string.char(0xde)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(3), op.hl_register_set_reference),

      -- set 4, a
      [string.char(0xe7)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(4), op.a_register),
      -- set 4, b
      [string.char(0xe0)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(4), op.b_register),
      -- set 4, c
      [string.char(0xe1)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(4), op.c_register),
      -- set 4, d
      [string.char(0xe2)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(4), op.d_register),
      -- set 4, e
      [string.char(0xe3)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(4), op.e_register),
      -- set 4, h
      [string.char(0xe4)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(4), op.h_register),
      -- set 4, l
      [string.char(0xe5)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(4), op.l_register),
      -- set 4, [hl]
      [string.char(0xe6)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(4), op.hl_register_set_reference),

      -- set 5, a
      [string.char(0xef)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(5), op.a_register),
      -- set 5, b
      [string.char(0xe8)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(5), op.b_register),
      -- set 5, c
      [string.char(0xe9)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(5), op.c_register),
      -- set 5, d
      [string.char(0xea)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(5), op.d_register),
      -- set 5, e
      [string.char(0xeb)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(5), op.e_register),
      -- set 5, h
      [string.char(0xec)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(5), op.h_register),
      -- set 5, l
      [string.char(0xed)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(5), op.l_register),
      -- set 5, [hl]
      [string.char(0xee)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(5), op.hl_register_set_reference),

      -- set 6, a
      [string.char(0xf7)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(6), op.a_register),
      -- set 6, b
      [string.char(0xf0)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(6), op.b_register),
      -- set 6, c
      [string.char(0xf1)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(6), op.c_register),
      -- set 6, d
      [string.char(0xf2)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(6), op.d_register),
      -- set 6, e
      [string.char(0xf3)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(6), op.e_register),
      -- set 6, h
      [string.char(0xf4)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(6), op.h_register),
      -- set 6, l
      [string.char(0xf5)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(6), op.l_register),
      -- set 6, [hl]
      [string.char(0xf6)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(6), op.hl_register_set_reference),

      -- set 7, a
      [string.char(0xff)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(7), op.a_register),
      -- set 7, b
      [string.char(0xf8)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(7), op.b_register),
      -- set 7, c
      [string.char(0xf9)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(7), op.c_register),
      -- set 7, d
      [string.char(0xfa)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(7), op.d_register),
      -- set 7, e
      [string.char(0xfb)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(7), op.e_register),
      -- set 7, h
      [string.char(0xfc)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(7), op.h_register),
      -- set 7, l
      [string.char(0xfd)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(7), op.l_register),
      -- set 7, [hl]
      [string.char(0xfe)] = create_extended_instruction_parser(
         "set", create_dynamic_byte_operand(7), op.hl_register_set_reference)
   }
}

-- TODO: handle reading over end of bank
local function read_next_instruction(file, max)
   max = max or 4000

   if max == 0 then
      return
   end

   local byte = file:read(1)
   if byte == nil then
      return
   end

   local parser = instructions[byte]
   local next_byte

   if not parser and max > 1 then
      local extended = extended_instructions[byte]
      if extended then
         next_byte = file:read(1)

         if next_byte then
            parser = extended[next_byte]
         end
      end
   end

   if parser and parser.size > max then
      parser = nil
   end

   -- TODO: handle unrecognized instructions
   if not parser then
      return create_instruction("nop", nil, nil, next_byte and 2 or 1)
   end

   local bytes, instruction = parser.read(file)

   -- TODO: handle remaining bytes
   -- TODO: handle bad instruction
   if not instruction then
      local nbytes = bytes and #bytes or 0
      return create_instruction("nop", nil, nil, (next_byte and 2 or 1) + nbytes)
   end

   return instruction
end

return {
   create_instruction = create_instruction,
   instructions = instructions,
   extended_instructions = extended_instructions,
   read_next_instruction = read_next_instruction
}
