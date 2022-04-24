-- TODO: remove unneeded args from classes

local function create_operand(value, reference, increment, offset, size)
   return {
      value = value,
      reference = reference or false,
      increment = increment or 0,
      offset = offset or 0,
      size = size or 1
   }
end

local function create_processor_register_operand(value, reference, increment, offset)
   return {
      value = value,
      reference = reference or false,
      increment = increment or 0,
      offset = offset or 0,
      size = 1,
      is_register = true
   }
end

local function create_processor_register_set_operand(value, reference, increment, offset)
   return {
      value = value,
      reference = reference or false,
      increment = increment or 0,
      offset = offset or 0,
      size = 2,
      is_register = true
   }
end

local function create_processor_register_set_reference_operand(
      value, increment, offset)
   return {
      value = value,
      reference = true,
      increment = increment or 0,
      offset = offset or 0,
      size = 2,
      is_register = true
   }
end

local function create_condition_operand(value)
   return {
      value = value,
      size = 1,
      is_condition = true
   }
end

local function create_vector_operand(value)
   return {
      value = value,
      size = 1,
      is_vector = true
   }
end

local function create_dynamic_octet_operand(value, reference, increment, offset)
   return {
      value = value,
      reference = reference or false,
      increment = increment or 0,
      offset = offset or 0,
      size = 2,
      is_dynamic = true
   }
end

local function create_dynamic_byte_operand(value, reference, increment, offset)
   return {
      value = value,
      reference = reference or false,
      increment = increment or 0,
      offset = offset or 0,
      size = 1,
      is_dynamic = true
   }
end

local a_register_op = create_processor_register_operand("a")
local f_register_op = create_processor_register_operand("f")
local b_register_op = create_processor_register_operand("b")
local c_register_op = create_processor_register_operand("c")
local d_register_op = create_processor_register_operand("d")
local e_register_op = create_processor_register_operand("e")
local h_register_op = create_processor_register_operand("h")
local l_register_op = create_processor_register_operand("l")

local af_register_set_op = create_processor_register_set_operand("af")
local bc_register_set_op = create_processor_register_set_operand("bc")
local de_register_set_op = create_processor_register_set_operand("de")
local hl_register_set_op = create_processor_register_set_operand("hl")

local sp_register_op = create_processor_register_operand("sp")

local c_register_reference_op = create_processor_register_operand("c", true)

local bc_register_set_reference_op = create_processor_register_set_reference_operand("bc")
local de_register_set_reference_op = create_processor_register_set_reference_operand("de")
local hl_register_set_reference_op = create_processor_register_set_reference_operand("hl")
local hl_inc_register_set_reference_op = create_processor_register_set_reference_operand("hl", 1)
local hl_dec_register_set_reference_op = create_processor_register_set_reference_operand("hl", -1)

local c_condition_op = create_condition_operand("c")
local z_condition_op = create_condition_operand("z")
local nc_condition_op = create_condition_operand("nc")
local nz_condition_op = create_condition_operand("nz")

local vector_00h_op = create_vector_operand(0x00)
local vector_08h_op = create_vector_operand(0x08)
local vector_10h_op = create_vector_operand(0x10)
local vector_18h_op = create_vector_operand(0x18)
local vector_20h_op = create_vector_operand(0x20)
local vector_28h_op = create_vector_operand(0x28)
local vector_30h_op = create_vector_operand(0x30)
local vector_38h_op = create_vector_operand(0x38)

local operands = {
   a_register = a_register_op,
   f_register = f_register_op,
   b_register = b_register_op,
   c_register = c_register_op,
   d_register = d_register_op,
   e_register = e_register_op,
   h_register = h_register_op,
   l_register = l_register_op,
   af_register_set = af_register_set_op,
   bc_register_set = bc_register_set_op,
   de_register_set = de_register_set_op,
   hl_register_set = hl_register_set_op,
   sp_register = sp_register_op,
   c_register_reference = c_register_reference_op,
   bc_register_set_reference = bc_register_set_reference_op,
   de_register_set_reference = de_register_set_reference_op,
   hl_register_set_reference = hl_register_set_reference_op,
   hl_inc_register_set_reference = hl_inc_register_set_reference_op,
   hl_dec_register_set_reference = hl_dec_register_set_reference_op,
   c_condition = c_condition_op,
   z_condition = z_condition_op,
   nc_condition = nc_condition_op,
   nz_condition = nz_condition_op,
   vector_00h = vector_00h_op,
   vector_08h = vector_08h_op,
   vector_10h = vector_10h_op,
   vector_18h = vector_18h_op,
   vector_20h = vector_20h_op,
   vector_28h = vector_28h_op,
   vector_30h = vector_30h_op,
   vector_38h = vector_38h_op
}

return {
   create_operand = create_operand,
   create_processor_register_operand = create_processor_register_operand,
   create_processor_register_set_operand = create_processor_register_set_operand,
   create_processor_register_set_reference_operand = create_processor_register_set_reference_operand,
   create_condition_operand = create_condition_operand,
   create_vector_operand = create_vector_operand,
   create_dynamic_octet_operand = create_dynamic_octet_operand,
   create_dynamic_byte_operand = create_dynamic_byte_operand,
   operands = operands
}
