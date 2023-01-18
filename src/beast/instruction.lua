-- TODO: handle rgbasm halt with nop

-- TODO: handle invalid instructions and do db instead
-- instructions that are too short
-- LDH A [(anything not in HRAM)]
-- LDH [(anything not in HRAM)], A

local function create_byte_op_instruction_parser(instruc)
    return {
        size = 2,
        parse = function(data, index)
            local char = data:sub(index, index)
            if not char then
                return
            end
            return { instruc = instruc, data = string.byte(char), size = 2 }
        end,
    }
end

local function create_octet_op_instruction_parser(instruc)
    return {
        size = 3,
        parse = function(data, index)
            local char1 = data:sub(index, index)
            if not char1 then
                return
            end

            index = index + 1

            local char2 = data:sub(index, index)
            if not char2 then
                return
            end

            local value = string.byte(char2) * 0x100 + string.byte(char1)

            return { instruc = instruc, data = value, size = 3 }
        end,
    }
end

local function create_signed_op_instruction_parser(instruc)
    return {
        size = 2,
        parse = function(data, index)
            local char = data:sub(index, index)
            if not char then
                return
            end

            local byte = string.byte(char)
            local value = (byte >= 0x80) and (byte - 256) or byte

            return { instruc = instruc, data = value, size = 2 }
        end,
    }
end

local instructions = {
    -- Control Instructions --

    [string.char(0x00)] = { instruc = "nop" },
    [string.char(0x76)] = { instruc = "halt" },
    [string.char(0xf3)] = { instruc = "di" },
    [string.char(0xfb)] = { instruc = "ei" },

    -- "ld" Instructions --

    [string.char(0x7f)] = { instruc = "ld a, a" },
    [string.char(0x78)] = { instruc = "ld a, b" },
    [string.char(0x79)] = { instruc = "ld a, c" },
    [string.char(0x7a)] = { instruc = "ld a, d" },
    [string.char(0x7b)] = { instruc = "ld a, e" },
    [string.char(0x7c)] = { instruc = "ld a, h" },
    [string.char(0x7d)] = { instruc = "ld a, l" },

    [string.char(0x47)] = { instruc = "ld b, a" },
    [string.char(0x40)] = { instruc = "ld b, b" },
    [string.char(0x41)] = { instruc = "ld b, c" },
    [string.char(0x42)] = { instruc = "ld b, d" },
    [string.char(0x43)] = { instruc = "ld b, e" },
    [string.char(0x44)] = { instruc = "ld b, h" },
    [string.char(0x45)] = { instruc = "ld b, l" },

    [string.char(0x4f)] = { instruc = "ld c, a" },
    [string.char(0x48)] = { instruc = "ld c, b" },
    [string.char(0x49)] = { instruc = "ld c, c" },
    [string.char(0x4a)] = { instruc = "ld c, d" },
    [string.char(0x4b)] = { instruc = "ld c, e" },
    [string.char(0x4c)] = { instruc = "ld c, h" },
    [string.char(0x4d)] = { instruc = "ld c, l" },

    [string.char(0x57)] = { instruc = "ld d, a" },
    [string.char(0x50)] = { instruc = "ld d, b" },
    [string.char(0x51)] = { instruc = "ld d, c" },
    [string.char(0x52)] = { instruc = "ld d, d" },
    [string.char(0x53)] = { instruc = "ld d, e" },
    [string.char(0x54)] = { instruc = "ld d, h" },
    [string.char(0x55)] = { instruc = "ld d, l" },

    [string.char(0x5f)] = { instruc = "ld e, a" },
    [string.char(0x58)] = { instruc = "ld e, b" },
    [string.char(0x59)] = { instruc = "ld e, c" },
    [string.char(0x5a)] = { instruc = "ld e, d" },
    [string.char(0x5b)] = { instruc = "ld e, e" },
    [string.char(0x5c)] = { instruc = "ld e, h" },
    [string.char(0x5d)] = { instruc = "ld e, l" },

    [string.char(0x67)] = { instruc = "ld h, a" },
    [string.char(0x60)] = { instruc = "ld h, b" },
    [string.char(0x61)] = { instruc = "ld h, c" },
    [string.char(0x62)] = { instruc = "ld h, d" },
    [string.char(0x63)] = { instruc = "ld h, e" },
    [string.char(0x64)] = { instruc = "ld h, h" },
    [string.char(0x65)] = { instruc = "ld h, l" },

    [string.char(0x6f)] = { instruc = "ld l, a" },
    [string.char(0x68)] = { instruc = "ld l, b" },
    [string.char(0x69)] = { instruc = "ld l, c" },
    [string.char(0x6a)] = { instruc = "ld l, d" },
    [string.char(0x6b)] = { instruc = "ld l, e" },
    [string.char(0x6c)] = { instruc = "ld l, h" },
    [string.char(0x6d)] = { instruc = "ld l, l" },

    [string.char(0x7e)] = { instruc = "ld a, [hl]" },
    [string.char(0x46)] = { instruc = "ld b, [hl]" },
    [string.char(0x4e)] = { instruc = "ld c, [hl]" },
    [string.char(0x56)] = { instruc = "ld d, [hl]" },
    [string.char(0x5e)] = { instruc = "ld e, [hl]" },
    [string.char(0x66)] = { instruc = "ld h, [hl]" },
    [string.char(0x6e)] = { instruc = "ld l, [hl]" },

    [string.char(0x77)] = { instruc = "ld [hl], a" },
    [string.char(0x70)] = { instruc = "ld [hl], b" },
    [string.char(0x71)] = { instruc = "ld [hl], c" },
    [string.char(0x72)] = { instruc = "ld [hl], d" },
    [string.char(0x73)] = { instruc = "ld [hl], e" },
    [string.char(0x74)] = { instruc = "ld [hl], h" },
    [string.char(0x75)] = { instruc = "ld [hl], l" },

    [string.char(0xf2)] = { instruc = "ld a, [$ff00+c]" },
    [string.char(0xe2)] = { instruc = "ld [$ff00+c], a" },

    [string.char(0x2a)] = { instruc = "ld a, [hl+]" },
    [string.char(0x3a)] = { instruc = "ld a, [hl-]" },
    [string.char(0x0a)] = { instruc = "ld a, [bc]" },
    [string.char(0x1a)] = { instruc = "ld a, [de]" },

    [string.char(0x22)] = { instruc = "ld [hl+], a" },
    [string.char(0x32)] = { instruc = "ld [hl-], a" },

    [string.char(0x02)] = { instruc = "ld [bc], a" },
    [string.char(0x12)] = { instruc = "ld [de], a" },

    -- Arithmetic Instructions --

    [string.char(0x87)] = { instruc = "add a, a" },
    [string.char(0x80)] = { instruc = "add a, b" },
    [string.char(0x81)] = { instruc = "add a, c" },
    [string.char(0x82)] = { instruc = "add a, d" },
    [string.char(0x83)] = { instruc = "add a, e" },
    [string.char(0x84)] = { instruc = "add a, h" },
    [string.char(0x85)] = { instruc = "add a, l" },

    [string.char(0x86)] = { instruc = "add a, [hl]" },

    [string.char(0x8f)] = { instruc = "adc a, a" },
    [string.char(0x88)] = { instruc = "adc a, b" },
    [string.char(0x89)] = { instruc = "adc a, c" },
    [string.char(0x8a)] = { instruc = "adc a, d" },
    [string.char(0x8b)] = { instruc = "adc a, e" },
    [string.char(0x8c)] = { instruc = "adc a, h" },
    [string.char(0x8d)] = { instruc = "adc a, l" },

    [string.char(0x8e)] = { instruc = "adc a, [hl]" },

    [string.char(0x97)] = { instruc = "sub a, a" },
    [string.char(0x90)] = { instruc = "sub a, b" },
    [string.char(0x91)] = { instruc = "sub a, c" },
    [string.char(0x92)] = { instruc = "sub a, d" },
    [string.char(0x93)] = { instruc = "sub a, e" },
    [string.char(0x94)] = { instruc = "sub a, h" },
    [string.char(0x95)] = { instruc = "sub a, l" },

    [string.char(0x96)] = { instruc = "sub a, [hl]" },

    [string.char(0x9f)] = { instruc = "sbc a, a" },
    [string.char(0x98)] = { instruc = "sbc a, b" },
    [string.char(0x99)] = { instruc = "sbc a, c" },
    [string.char(0x9a)] = { instruc = "sbc a, d" },
    [string.char(0x9b)] = { instruc = "sbc a, e" },
    [string.char(0x9c)] = { instruc = "sbc a, h" },
    [string.char(0x9d)] = { instruc = "sbc a, l" },

    [string.char(0x9e)] = { instruc = "sbc a, [hl]" },

    [string.char(0x29)] = { instruc = "add hl, hl" },
    [string.char(0x09)] = { instruc = "add hl, bc" },
    [string.char(0x19)] = { instruc = "add hl, de" },

    [string.char(0x27)] = { instruc = "daa" },
    [string.char(0x37)] = { instruc = "scf" },

    -- Logical Instructions --

    [string.char(0xa7)] = { instruc = "and a, a" },
    [string.char(0xa0)] = { instruc = "and a, b" },
    [string.char(0xa1)] = { instruc = "and a, c" },
    [string.char(0xa2)] = { instruc = "and a, d" },
    [string.char(0xa3)] = { instruc = "and a, e" },
    [string.char(0xa4)] = { instruc = "and a, h" },
    [string.char(0xa5)] = { instruc = "and a, l" },

    [string.char(0xa6)] = { instruc = "and a, [hl]" },

    [string.char(0xaf)] = { instruc = "xor a, a" },
    [string.char(0xa8)] = { instruc = "xor a, b" },
    [string.char(0xa9)] = { instruc = "xor a, c" },
    [string.char(0xaa)] = { instruc = "xor a, d" },
    [string.char(0xab)] = { instruc = "xor a, e" },
    [string.char(0xac)] = { instruc = "xor a, h" },
    [string.char(0xad)] = { instruc = "xor a, l" },

    [string.char(0xae)] = { instruc = "xor a, [hl]" },

    [string.char(0xb7)] = { instruc = "or a, a" },
    [string.char(0xb0)] = { instruc = "or a, b" },
    [string.char(0xb1)] = { instruc = "or a, c" },
    [string.char(0xb2)] = { instruc = "or a, d" },
    [string.char(0xb3)] = { instruc = "or a, e" },
    [string.char(0xb4)] = { instruc = "or a, h" },
    [string.char(0xb5)] = { instruc = "or a, l" },

    [string.char(0xb6)] = { instruc = "or a, [hl]" },

    [string.char(0xbf)] = { instruc = "cp a, a" },
    [string.char(0xb8)] = { instruc = "cp a, b" },
    [string.char(0xb9)] = { instruc = "cp a, c" },
    [string.char(0xba)] = { instruc = "cp a, d" },
    [string.char(0xbb)] = { instruc = "cp a, e" },
    [string.char(0xbc)] = { instruc = "cp a, h" },
    [string.char(0xbd)] = { instruc = "cp a, l" },

    [string.char(0xbe)] = { instruc = "cp a, [hl]" },

    [string.char(0x2f)] = { instruc = "cpl" },
    [string.char(0x3f)] = { instruc = "ccf" },

    -- Shift/Rotation Instructions --

    [string.char(0x07)] = { instruc = "rlca" },
    [string.char(0x17)] = { instruc = "rla" },

    [string.char(0x0f)] = { instruc = "rrca" },
    [string.char(0x1f)] = { instruc = "rra" },

    [string.char(0x3c)] = { instruc = "inc a" },
    [string.char(0x04)] = { instruc = "inc b" },
    [string.char(0x0c)] = { instruc = "inc c" },
    [string.char(0x14)] = { instruc = "inc d" },
    [string.char(0x1c)] = { instruc = "inc e" },
    [string.char(0x24)] = { instruc = "inc h" },
    [string.char(0x2c)] = { instruc = "inc l" },

    [string.char(0x23)] = { instruc = "inc hl" },
    [string.char(0x03)] = { instruc = "inc bc" },
    [string.char(0x13)] = { instruc = "inc de" },

    [string.char(0x34)] = { instruc = "inc [hl]" },

    [string.char(0x3d)] = { instruc = "dec a" },
    [string.char(0x05)] = { instruc = "dec b" },
    [string.char(0x0d)] = { instruc = "dec c" },
    [string.char(0x15)] = { instruc = "dec d" },
    [string.char(0x1d)] = { instruc = "dec e" },
    [string.char(0x25)] = { instruc = "dec h" },
    [string.char(0x2d)] = { instruc = "dec l" },

    [string.char(0x2b)] = { instruc = "dec hl" },
    [string.char(0x0b)] = { instruc = "dec bc" },
    [string.char(0x1b)] = { instruc = "dec de" },

    [string.char(0x35)] = { instruc = "dec [hl]" },

    -- Stack Instructions --

    [string.char(0xf5)] = { instruc = "push af" },
    [string.char(0xc5)] = { instruc = "push bc" },
    [string.char(0xd5)] = { instruc = "push de" },
    [string.char(0xe5)] = { instruc = "push hl" },

    [string.char(0xf1)] = { instruc = "pop af" },
    [string.char(0xc1)] = { instruc = "pop bc" },
    [string.char(0xd1)] = { instruc = "pop de" },
    [string.char(0xe1)] = { instruc = "pop hl" },

    [string.char(0x33)] = { instruc = "inc sp" },
    [string.char(0x3b)] = { instruc = "dec sp" },

    [string.char(0xf9)] = { instruc = "ld sp, hl" },
    [string.char(0x39)] = { instruc = "add hl, sp" },

    -- Jump/Call Instructions --

    [string.char(0xe9)] = { instruc = "jp hl" },

    [string.char(0xc7)] = { instruc = "rst $00" },
    [string.char(0xcf)] = { instruc = "rst $08" },
    [string.char(0xd7)] = { instruc = "rst $10" },
    [string.char(0xdf)] = { instruc = "rst $18" },
    [string.char(0xe7)] = { instruc = "rst $20" },
    [string.char(0xef)] = { instruc = "rst $28" },
    [string.char(0xf7)] = { instruc = "rst $30" },
    [string.char(0xff)] = { instruc = "rst $38" },

    [string.char(0xc9)] = { instruc = "ret", code_end = true },
    [string.char(0xd9)] = { instruc = "reti", code_end = true },
    [string.char(0xd8)] = { instruc = "ret c" },
    [string.char(0xc8)] = { instruc = "ret z" },
    [string.char(0xd0)] = { instruc = "ret nc" },
    [string.char(0xc0)] = { instruc = "ret nz" },
}

local extended_instructions = {
    [string.char(0x10)] = {
        [string.char(0x00)] = { instruc = "stop", size = 2 },
    },
    [string.char(0xcb)] = {
        -- "rlc" Instructions --

        [string.char(0x07)] = { instruc = "rlc a", size = 2 },
        [string.char(0x00)] = { instruc = "rlc b", size = 2 },
        [string.char(0x01)] = { instruc = "rlc c", size = 2 },
        [string.char(0x02)] = { instruc = "rlc d", size = 2 },
        [string.char(0x03)] = { instruc = "rlc e", size = 2 },
        [string.char(0x04)] = { instruc = "rlc h", size = 2 },
        [string.char(0x05)] = { instruc = "rlc l", size = 2 },
        [string.char(0x06)] = { instruc = "rlc [hl]", size = 2 },

        -- "rrc" Instructions --

        [string.char(0x0f)] = { instruc = "rrc a", size = 2 },
        [string.char(0x08)] = { instruc = "rrc b", size = 2 },
        [string.char(0x09)] = { instruc = "rrc c", size = 2 },
        [string.char(0x0a)] = { instruc = "rrc d", size = 2 },
        [string.char(0x0b)] = { instruc = "rrc e", size = 2 },
        [string.char(0x0c)] = { instruc = "rrc h", size = 2 },
        [string.char(0x0d)] = { instruc = "rrc l", size = 2 },
        [string.char(0x0e)] = { instruc = "rrc [hl]", size = 2 },

        -- "rl" Instructions --

        [string.char(0x17)] = { instruc = "rl a", size = 2 },
        [string.char(0x10)] = { instruc = "rl b", size = 2 },
        [string.char(0x11)] = { instruc = "rl c", size = 2 },
        [string.char(0x12)] = { instruc = "rl d", size = 2 },
        [string.char(0x13)] = { instruc = "rl e", size = 2 },
        [string.char(0x14)] = { instruc = "rl h", size = 2 },
        [string.char(0x15)] = { instruc = "rl l", size = 2 },
        [string.char(0x16)] = { instruc = "rl [hl]", size = 2 },

        -- "rr" Instructions --

        [string.char(0x1f)] = { instruc = "rr a", size = 2 },
        [string.char(0x18)] = { instruc = "rr b", size = 2 },
        [string.char(0x19)] = { instruc = "rr c", size = 2 },
        [string.char(0x1a)] = { instruc = "rr d", size = 2 },
        [string.char(0x1b)] = { instruc = "rr e", size = 2 },
        [string.char(0x1c)] = { instruc = "rr h", size = 2 },
        [string.char(0x1d)] = { instruc = "rr l", size = 2 },
        [string.char(0x1e)] = { instruc = "rr [hl]", size = 2 },

        -- "sla" Instructions --

        [string.char(0x27)] = { instruc = "sla a", size = 2 },
        [string.char(0x20)] = { instruc = "sla b", size = 2 },
        [string.char(0x21)] = { instruc = "sla c", size = 2 },
        [string.char(0x22)] = { instruc = "sla d", size = 2 },
        [string.char(0x23)] = { instruc = "sla e", size = 2 },
        [string.char(0x24)] = { instruc = "sla h", size = 2 },
        [string.char(0x25)] = { instruc = "sla l", size = 2 },
        [string.char(0x26)] = { instruc = "sla [hl]", size = 2 },

        -- "sra" Instructions --

        [string.char(0x2f)] = { instruc = "sra a", size = 2 },
        [string.char(0x28)] = { instruc = "sra b", size = 2 },
        [string.char(0x29)] = { instruc = "sra c", size = 2 },
        [string.char(0x2a)] = { instruc = "sra d", size = 2 },
        [string.char(0x2b)] = { instruc = "sra e", size = 2 },
        [string.char(0x2c)] = { instruc = "sra h", size = 2 },
        [string.char(0x2d)] = { instruc = "sra l", size = 2 },
        [string.char(0x2e)] = { instruc = "sra [hl]", size = 2 },

        -- "swap" Instructions --

        [string.char(0x37)] = { instruc = "swap a", size = 2 },
        [string.char(0x30)] = { instruc = "swap b", size = 2 },
        [string.char(0x31)] = { instruc = "swap c", size = 2 },
        [string.char(0x32)] = { instruc = "swap d", size = 2 },
        [string.char(0x33)] = { instruc = "swap e", size = 2 },
        [string.char(0x34)] = { instruc = "swap h", size = 2 },
        [string.char(0x35)] = { instruc = "swap l", size = 2 },
        [string.char(0x36)] = { instruc = "swap [hl]", size = 2 },

        -- "srl" Instructions --

        [string.char(0x3f)] = { instruc = "srl a", size = 2 },
        [string.char(0x38)] = { instruc = "srl b", size = 2 },
        [string.char(0x39)] = { instruc = "srl c", size = 2 },
        [string.char(0x3a)] = { instruc = "srl d", size = 2 },
        [string.char(0x3b)] = { instruc = "srl e", size = 2 },
        [string.char(0x3c)] = { instruc = "srl h", size = 2 },
        [string.char(0x3d)] = { instruc = "srl l", size = 2 },
        [string.char(0x3e)] = { instruc = "srl [hl]", size = 2 },

        -- "bit" Instructions --

        [string.char(0x47)] = { instruc = "bit 0, a", size = 2 },
        [string.char(0x40)] = { instruc = "bit 0, b", size = 2 },
        [string.char(0x41)] = { instruc = "bit 0, c", size = 2 },
        [string.char(0x42)] = { instruc = "bit 0, d", size = 2 },
        [string.char(0x43)] = { instruc = "bit 0, e", size = 2 },
        [string.char(0x44)] = { instruc = "bit 0, h", size = 2 },
        [string.char(0x45)] = { instruc = "bit 0, l", size = 2 },
        [string.char(0x46)] = { instruc = "bit 0, [hl]", size = 2 },

        [string.char(0x4f)] = { instruc = "bit 1, a", size = 2 },
        [string.char(0x48)] = { instruc = "bit 1, b", size = 2 },
        [string.char(0x49)] = { instruc = "bit 1, c", size = 2 },
        [string.char(0x4a)] = { instruc = "bit 1, d", size = 2 },
        [string.char(0x4b)] = { instruc = "bit 1, e", size = 2 },
        [string.char(0x4c)] = { instruc = "bit 1, h", size = 2 },
        [string.char(0x4d)] = { instruc = "bit 1, l", size = 2 },
        [string.char(0x4e)] = { instruc = "bit 1, [hl]", size = 2 },

        [string.char(0x57)] = { instruc = "bit 2, a", size = 2 },
        [string.char(0x50)] = { instruc = "bit 2, b", size = 2 },
        [string.char(0x51)] = { instruc = "bit 2, c", size = 2 },
        [string.char(0x52)] = { instruc = "bit 2, d", size = 2 },
        [string.char(0x53)] = { instruc = "bit 2, e", size = 2 },
        [string.char(0x54)] = { instruc = "bit 2, h", size = 2 },
        [string.char(0x55)] = { instruc = "bit 2, l", size = 2 },
        [string.char(0x56)] = { instruc = "bit 2, [hl]", size = 2 },

        [string.char(0x5f)] = { instruc = "bit 3, a", size = 2 },
        [string.char(0x58)] = { instruc = "bit 3, b", size = 2 },
        [string.char(0x59)] = { instruc = "bit 3, c", size = 2 },
        [string.char(0x5a)] = { instruc = "bit 3, d", size = 2 },
        [string.char(0x5b)] = { instruc = "bit 3, e", size = 2 },
        [string.char(0x5c)] = { instruc = "bit 3, h", size = 2 },
        [string.char(0x5d)] = { instruc = "bit 3, l", size = 2 },
        [string.char(0x5e)] = { instruc = "bit 3, [hl]", size = 2 },

        [string.char(0x67)] = { instruc = "bit 4, a", size = 2 },
        [string.char(0x60)] = { instruc = "bit 4, b", size = 2 },
        [string.char(0x61)] = { instruc = "bit 4, c", size = 2 },
        [string.char(0x62)] = { instruc = "bit 4, d", size = 2 },
        [string.char(0x63)] = { instruc = "bit 4, e", size = 2 },
        [string.char(0x64)] = { instruc = "bit 4, h", size = 2 },
        [string.char(0x65)] = { instruc = "bit 4, l", size = 2 },
        [string.char(0x66)] = { instruc = "bit 4, [hl]", size = 2 },

        [string.char(0x6f)] = { instruc = "bit 5, a", size = 2 },
        [string.char(0x68)] = { instruc = "bit 5, b", size = 2 },
        [string.char(0x69)] = { instruc = "bit 5, c", size = 2 },
        [string.char(0x6a)] = { instruc = "bit 5, d", size = 2 },
        [string.char(0x6b)] = { instruc = "bit 5, e", size = 2 },
        [string.char(0x6c)] = { instruc = "bit 5, h", size = 2 },
        [string.char(0x6d)] = { instruc = "bit 5, l", size = 2 },
        [string.char(0x6e)] = { instruc = "bit 5, [hl]", size = 2 },

        [string.char(0x77)] = { instruc = "bit 6, a", size = 2 },
        [string.char(0x70)] = { instruc = "bit 6, b", size = 2 },
        [string.char(0x71)] = { instruc = "bit 6, c", size = 2 },
        [string.char(0x72)] = { instruc = "bit 6, d", size = 2 },
        [string.char(0x73)] = { instruc = "bit 6, e", size = 2 },
        [string.char(0x74)] = { instruc = "bit 6, h", size = 2 },
        [string.char(0x75)] = { instruc = "bit 6, l", size = 2 },
        [string.char(0x76)] = { instruc = "bit 6, [hl]", size = 2 },

        [string.char(0x7f)] = { instruc = "bit 7, a", size = 2 },
        [string.char(0x78)] = { instruc = "bit 7, b", size = 2 },
        [string.char(0x79)] = { instruc = "bit 7, c", size = 2 },
        [string.char(0x7a)] = { instruc = "bit 7, d", size = 2 },
        [string.char(0x7b)] = { instruc = "bit 7, e", size = 2 },
        [string.char(0x7c)] = { instruc = "bit 7, h", size = 2 },
        [string.char(0x7d)] = { instruc = "bit 7, l", size = 2 },
        [string.char(0x7e)] = { instruc = "bit 7, [hl]", size = 2 },

        -- "res" Instructions --

        [string.char(0x87)] = { instruc = "res 0, a", size = 2 },
        [string.char(0x80)] = { instruc = "res 0, b", size = 2 },
        [string.char(0x81)] = { instruc = "res 0, c", size = 2 },
        [string.char(0x82)] = { instruc = "res 0, d", size = 2 },
        [string.char(0x83)] = { instruc = "res 0, e", size = 2 },
        [string.char(0x84)] = { instruc = "res 0, h", size = 2 },
        [string.char(0x85)] = { instruc = "res 0, l", size = 2 },
        [string.char(0x86)] = { instruc = "res 0, [hl]", size = 2 },

        [string.char(0x8f)] = { instruc = "res 1, a", size = 2 },
        [string.char(0x88)] = { instruc = "res 1, b", size = 2 },
        [string.char(0x89)] = { instruc = "res 1, c", size = 2 },
        [string.char(0x8a)] = { instruc = "res 1, d", size = 2 },
        [string.char(0x8b)] = { instruc = "res 1, e", size = 2 },
        [string.char(0x8c)] = { instruc = "res 1, h", size = 2 },
        [string.char(0x8d)] = { instruc = "res 1, l", size = 2 },
        [string.char(0x8e)] = { instruc = "res 1, [hl]", size = 2 },

        [string.char(0x97)] = { instruc = "res 2, a", size = 2 },
        [string.char(0x90)] = { instruc = "res 2, b", size = 2 },
        [string.char(0x91)] = { instruc = "res 2, c", size = 2 },
        [string.char(0x92)] = { instruc = "res 2, d", size = 2 },
        [string.char(0x93)] = { instruc = "res 2, e", size = 2 },
        [string.char(0x94)] = { instruc = "res 2, h", size = 2 },
        [string.char(0x95)] = { instruc = "res 2, l", size = 2 },
        [string.char(0x96)] = { instruc = "res 2, [hl]", size = 2 },

        [string.char(0x9f)] = { instruc = "res 3, a", size = 2 },
        [string.char(0x98)] = { instruc = "res 3, b", size = 2 },
        [string.char(0x99)] = { instruc = "res 3, c", size = 2 },
        [string.char(0x9a)] = { instruc = "res 3, d", size = 2 },
        [string.char(0x9b)] = { instruc = "res 3, e", size = 2 },
        [string.char(0x9c)] = { instruc = "res 3, h", size = 2 },
        [string.char(0x9d)] = { instruc = "res 3, l", size = 2 },
        [string.char(0x9e)] = { instruc = "res 3, [hl]", size = 2 },

        [string.char(0xa7)] = { instruc = "res 4, a", size = 2 },
        [string.char(0xa0)] = { instruc = "res 4, b", size = 2 },
        [string.char(0xa1)] = { instruc = "res 4, c", size = 2 },
        [string.char(0xa2)] = { instruc = "res 4, d", size = 2 },
        [string.char(0xa3)] = { instruc = "res 4, e", size = 2 },
        [string.char(0xa4)] = { instruc = "res 4, h", size = 2 },
        [string.char(0xa5)] = { instruc = "res 4, l", size = 2 },
        [string.char(0xa6)] = { instruc = "res 4, [hl]", size = 2 },

        [string.char(0xaf)] = { instruc = "res 5, a", size = 2 },
        [string.char(0xa8)] = { instruc = "res 5, b", size = 2 },
        [string.char(0xa9)] = { instruc = "res 5, c", size = 2 },
        [string.char(0xaa)] = { instruc = "res 5, d", size = 2 },
        [string.char(0xab)] = { instruc = "res 5, e", size = 2 },
        [string.char(0xac)] = { instruc = "res 5, h", size = 2 },
        [string.char(0xad)] = { instruc = "res 5, l", size = 2 },
        [string.char(0xae)] = { instruc = "res 5, [hl]", size = 2 },

        [string.char(0xb7)] = { instruc = "res 6, a", size = 2 },
        [string.char(0xb0)] = { instruc = "res 6, b", size = 2 },
        [string.char(0xb1)] = { instruc = "res 6, c", size = 2 },
        [string.char(0xb2)] = { instruc = "res 6, d", size = 2 },
        [string.char(0xb3)] = { instruc = "res 6, e", size = 2 },
        [string.char(0xb4)] = { instruc = "res 6, h", size = 2 },
        [string.char(0xb5)] = { instruc = "res 6, l", size = 2 },
        [string.char(0xb6)] = { instruc = "res 6, [hl]", size = 2 },

        [string.char(0xbf)] = { instruc = "res 7, a", size = 2 },
        [string.char(0xb8)] = { instruc = "res 7, b", size = 2 },
        [string.char(0xb9)] = { instruc = "res 7, c", size = 2 },
        [string.char(0xba)] = { instruc = "res 7, d", size = 2 },
        [string.char(0xbb)] = { instruc = "res 7, e", size = 2 },
        [string.char(0xbc)] = { instruc = "res 7, h", size = 2 },
        [string.char(0xbd)] = { instruc = "res 7, l", size = 2 },
        [string.char(0xbe)] = { instruc = "res 7, [hl]", size = 2 },

        -- "set" Instructions --

        [string.char(0xc7)] = { instruc = "set 0, a", size = 2 },
        [string.char(0xc0)] = { instruc = "set 0, b", size = 2 },
        [string.char(0xc1)] = { instruc = "set 0, c", size = 2 },
        [string.char(0xc2)] = { instruc = "set 0, d", size = 2 },
        [string.char(0xc3)] = { instruc = "set 0, e", size = 2 },
        [string.char(0xc4)] = { instruc = "set 0, h", size = 2 },
        [string.char(0xc5)] = { instruc = "set 0, l", size = 2 },
        [string.char(0xc6)] = { instruc = "set 0, [hl]", size = 2 },

        [string.char(0xcf)] = { instruc = "set 1, a", size = 2 },
        [string.char(0xc8)] = { instruc = "set 1, b", size = 2 },
        [string.char(0xc9)] = { instruc = "set 1, c", size = 2 },
        [string.char(0xca)] = { instruc = "set 1, d", size = 2 },
        [string.char(0xcb)] = { instruc = "set 1, e", size = 2 },
        [string.char(0xcc)] = { instruc = "set 1, h", size = 2 },
        [string.char(0xcd)] = { instruc = "set 1, l", size = 2 },
        [string.char(0xce)] = { instruc = "set 1, [hl]", size = 2 },

        [string.char(0xd7)] = { instruc = "set 2, a", size = 2 },
        [string.char(0xd0)] = { instruc = "set 2, b", size = 2 },
        [string.char(0xd1)] = { instruc = "set 2, c", size = 2 },
        [string.char(0xd2)] = { instruc = "set 2, d", size = 2 },
        [string.char(0xd3)] = { instruc = "set 2, e", size = 2 },
        [string.char(0xd4)] = { instruc = "set 2, h", size = 2 },
        [string.char(0xd5)] = { instruc = "set 2, l", size = 2 },
        [string.char(0xd6)] = { instruc = "set 2, [hl]", size = 2 },

        [string.char(0xdf)] = { instruc = "set 3, a", size = 2 },
        [string.char(0xd8)] = { instruc = "set 3, b", size = 2 },
        [string.char(0xd9)] = { instruc = "set 3, c", size = 2 },
        [string.char(0xda)] = { instruc = "set 3, d", size = 2 },
        [string.char(0xdb)] = { instruc = "set 3, e", size = 2 },
        [string.char(0xdc)] = { instruc = "set 3, h", size = 2 },
        [string.char(0xdd)] = { instruc = "set 3, l", size = 2 },
        [string.char(0xde)] = { instruc = "set 3, [hl]", size = 2 },

        [string.char(0xe7)] = { instruc = "set 4, a", size = 2 },
        [string.char(0xe0)] = { instruc = "set 4, b", size = 2 },
        [string.char(0xe1)] = { instruc = "set 4, c", size = 2 },
        [string.char(0xe2)] = { instruc = "set 4, d", size = 2 },
        [string.char(0xe3)] = { instruc = "set 4, e", size = 2 },
        [string.char(0xe4)] = { instruc = "set 4, h", size = 2 },
        [string.char(0xe5)] = { instruc = "set 4, l", size = 2 },
        [string.char(0xe6)] = { instruc = "set 4, [hl]", size = 2 },

        [string.char(0xef)] = { instruc = "set 5, a", size = 2 },
        [string.char(0xe8)] = { instruc = "set 5, b", size = 2 },
        [string.char(0xe9)] = { instruc = "set 5, c", size = 2 },
        [string.char(0xea)] = { instruc = "set 5, d", size = 2 },
        [string.char(0xeb)] = { instruc = "set 5, e", size = 2 },
        [string.char(0xec)] = { instruc = "set 5, h", size = 2 },
        [string.char(0xed)] = { instruc = "set 5, l", size = 2 },
        [string.char(0xee)] = { instruc = "set 5, [hl]", size = 2 },

        [string.char(0xf7)] = { instruc = "set 6, a", size = 2 },
        [string.char(0xf0)] = { instruc = "set 6, b", size = 2 },
        [string.char(0xf1)] = { instruc = "set 6, c", size = 2 },
        [string.char(0xf2)] = { instruc = "set 6, d", size = 2 },
        [string.char(0xf3)] = { instruc = "set 6, e", size = 2 },
        [string.char(0xf4)] = { instruc = "set 6, h", size = 2 },
        [string.char(0xf5)] = { instruc = "set 6, l", size = 2 },
        [string.char(0xf6)] = { instruc = "set 6, [hl]", size = 2 },

        [string.char(0xff)] = { instruc = "set 7, a", size = 2 },
        [string.char(0xf8)] = { instruc = "set 7, b", size = 2 },
        [string.char(0xf9)] = { instruc = "set 7, c", size = 2 },
        [string.char(0xfa)] = { instruc = "set 7, d", size = 2 },
        [string.char(0xfb)] = { instruc = "set 7, e", size = 2 },
        [string.char(0xfc)] = { instruc = "set 7, h", size = 2 },
        [string.char(0xfd)] = { instruc = "set 7, l", size = 2 },
        [string.char(0xfe)] = { instruc = "set 7, [hl]", size = 2 },
    },
}

local instruction_parsers = {
    -- "ld" Instructions --

    [string.char(0x3e)] = create_byte_op_instruction_parser("ld a, n8"),
    [string.char(0x06)] = create_byte_op_instruction_parser("ld b, n8"),
    [string.char(0x0e)] = create_byte_op_instruction_parser("ld c, n8"),
    [string.char(0x16)] = create_byte_op_instruction_parser("ld d, n8"),
    [string.char(0x1e)] = create_byte_op_instruction_parser("ld e, n8"),
    [string.char(0x26)] = create_byte_op_instruction_parser("ld h, n8"),
    [string.char(0x2e)] = create_byte_op_instruction_parser("ld l, n8"),

    [string.char(0xfa)] = create_octet_op_instruction_parser("ld a, [n16]"),
    [string.char(0xea)] = create_octet_op_instruction_parser("ld [n16], a"),

    [string.char(0xf0)] = create_byte_op_instruction_parser("ldio a, [$ff00+n8]"),
    [string.char(0xe0)] = create_byte_op_instruction_parser("ldio [$ff00+n8], a"),

    [string.char(0x36)] = create_byte_op_instruction_parser("ld [hl], n8"),

    [string.char(0x21)] = create_octet_op_instruction_parser("ld hl, n16"),
    [string.char(0x01)] = create_octet_op_instruction_parser("ld bc, n16"),
    [string.char(0x11)] = create_octet_op_instruction_parser("ld de, n16"),

    -- Arithmetic Instructions --

    [string.char(0xc6)] = create_byte_op_instruction_parser("add a, n8"),
    [string.char(0xce)] = create_byte_op_instruction_parser("adc a, n8"),
    [string.char(0xd6)] = create_byte_op_instruction_parser("sub a, n8"),
    [string.char(0xde)] = create_byte_op_instruction_parser("sbc a, n8"),
    [string.char(0xe6)] = create_byte_op_instruction_parser("and a, n8"),

    -- Logical Instructions --

    [string.char(0xee)] = create_byte_op_instruction_parser("xor a, n8"),
    [string.char(0xf6)] = create_byte_op_instruction_parser("or a, n8"),
    [string.char(0xfe)] = create_byte_op_instruction_parser("cp a, n8"),

    -- Stack Instructions --

    [string.char(0xe8)] = create_signed_op_instruction_parser("add sp, e8"),
    [string.char(0xf8)] = create_signed_op_instruction_parser("ld hl, sp+e8"),

    [string.char(0x31)] = create_octet_op_instruction_parser("ld sp, n16"),
    [string.char(0x08)] = create_octet_op_instruction_parser("ld [n16], sp"),

    -- Jump/Call Instructions --

    [string.char(0xcd)] = create_octet_op_instruction_parser("call n16"),
    [string.char(0xdc)] = create_octet_op_instruction_parser("call c, n16"),
    [string.char(0xcc)] = create_octet_op_instruction_parser("call z, n16"),
    [string.char(0xd4)] = create_octet_op_instruction_parser("call nc, n16"),
    [string.char(0xc4)] = create_octet_op_instruction_parser("call nz, n16"),

    [string.char(0x18)] = create_signed_op_instruction_parser("jr e8"),
    [string.char(0x38)] = create_signed_op_instruction_parser("jr c, e8"),
    [string.char(0x28)] = create_signed_op_instruction_parser("jr z, e8"),
    [string.char(0x30)] = create_signed_op_instruction_parser("jr nc, e8"),
    [string.char(0x20)] = create_signed_op_instruction_parser("jr nz, e8"),

    [string.char(0xc3)] = create_octet_op_instruction_parser("jp n16"),
    [string.char(0xda)] = create_octet_op_instruction_parser("jp c, n16"),
    [string.char(0xca)] = create_octet_op_instruction_parser("jp z, n16"),
    [string.char(0xd2)] = create_octet_op_instruction_parser("jp nc, n16"),
    [string.char(0xc2)] = create_octet_op_instruction_parser("jp nz, n16"),
}

local function parse_next_instruction(data, address, max)
    max = max or (0x4000 - (address % 0x4000))

    if max == 0 then
        return
    end

    local index = address + 1

    local char = data:sub(index, index)
    if not char then
        return
    end
    index = index + 1

    local instruction = instructions[char]
    local extra_byte

    if not instruction then
        local parser = instruction_parsers[char]

        if parser then
            -- Read using instruction parser

            if (parser.size or 2) <= max then
                instruction = parser.parse(data, index)
            end
        elseif max > 1 then
            -- Find extended instruction

            local byte_extended_instructions = extended_instructions[char]

            if byte_extended_instructions then
                extra_byte = data:sub(index, index)

                if extra_byte then
                    instruction = byte_extended_instructions[extra_byte]
                end
            end
        end
    end

    return instruction
end

return {
    parse_next_instruction = parse_next_instruction,
}
