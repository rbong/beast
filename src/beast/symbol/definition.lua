local function create_region_definition(region_type, size)
   return {
      region_type = region_type,
      size = size
   }
end

local function create_replacement_definition(size, value)
   return {
      region_type = "replace",
      size = size,
      value = value
   }
end

local function create_operand_definitions(left_op, right_op)
   return {
      left_op = left_op,
      right_op = right_op
   }
end

local function set_left_op_definition(def, left_op)
   def.left_op = left_op
end

local function set_right_op_definition(def, right_op)
   def.right_op = right_op
end

local function create_definition_collection()
   return {
      definitions = {}
   }
end

local function add_definition(collection, address, definition)
   -- TODO: handle duplicate definitions (configurable)
   collection.definitions[address] = definition
end

local function insert_definition(collection, address, value)
   if collection.definitions[address] then
      table.insert(collection.definitions[address], value)
   else
      collection.definitions[address] = { value }
   end
end

local function get_definition(collection, address)
   return collection.definitions[address]
end

return {
   create_region_definition = create_region_definition,
   create_replacement_definition = create_replacement_definition,
   create_operand_definitions = create_operand_definitions,
   set_left_op_definition = set_left_op_definition,
   set_right_op_definition = set_right_op_definition,
   create_definition_collection = create_definition_collection,
   add_definition = add_definition,
   insert_definition = insert_definition,
   get_definition = get_definition
}
