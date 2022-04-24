local function create_line_reader(line)
   return {
      index = 1,
      line = line,
      len = #line
   }
end

local function read_pattern(reader, pattern, offset)
   local _, pattern_end, group = reader.line:find(pattern, reader.index)
   if pattern_end then
      pattern_end = pattern_end + 1
      reader.index = pattern_end + (offset or 0)
   end
   return pattern_end, group
end

local function read_hex_pattern(reader, pattern, offset)
   local pattern_end, group = read_pattern(reader, pattern, offset)
   if group then
      group = tonumber(group, 16)
   end
   return pattern_end, group
end

local function read_rest(reader)
   return reader.len, reader.line:sub(reader.index)
end

local function has_remaining(reader)
   -- TODO: should this be using ~=?
   return reader.index ~= reader.len
end

return {
   create_line_reader = create_line_reader,
   read_pattern = read_pattern,
   read_hex_pattern = read_hex_pattern,
   read_rest = read_rest,
   has_remaining = has_remaining
}
