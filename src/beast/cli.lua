local create_options = require("beast/option").create_options

local arg_opts = {}

local function add_arg_opt(short_arg, long_arg, arg_opt)
   arg_opt = arg_opt or {}

   arg_opt.short_arg = short_arg

   if short_arg then
      arg_opts[short_arg] = arg_opt
   end

   if long_arg then
      arg_opts[long_arg] = arg_opt
      if not arg_opt.opt_name then
         arg_opt.opt_name = long_arg:sub(3)
      end
   end

   return arg_opt
end

add_arg_opt("-h", "--help")
add_arg_opt("-v", "--version")

add_arg_opt("-s", "--symbols")

add_arg_opt("-nwo", "--no-warn-overlaps", { opt_name = "no_warn_overlaps" })

local function _parse_arg(options, args, nargs, i)
   local arg = args[i]

   local _, match_end, name, equals, value = arg:find("(-[^=]+)(=?)(.*)")
   i = i + 1

   -- Ignore remaining args
   if name == "--" and equals == "" then
      return nargs + 1
   end

   -- No arg, assume this is the ROM path
   if not match_end then
      options.rom_path = arg
      return i
   end

   -- Get arg option
   local arg_opt = arg_opts[name]
   if not arg_opt then
      -- TODO: print usage
      error(string.format("Unrecognized argument: '%s'", name))
   end

   -- Handle special arguments
   if arg_opt.opt_name == "help" then
      -- TODO
      os.exit(0)
   end
   if arg_opt.opt_name == "version" then
      -- TODO
      os.exit(0)
   end

   -- Handle flags
   if arg_opt.flag_value ~= nil then
      options[arg_opt.opt_name] = arg_opt.flag_value
      return i
   end

   -- Get value
   if equals == "" then
      if i > nargs then
         error(string.format("Reached end of arguments before reaching value for: '%s'", name))
      end

      value = args[i]
      i = i + 1
   end

   -- Set option
   options[arg_opt.opt_name] = value
   return i
end

local function parse_args(args)
   local options = create_options()

   local i = 1
   local nargs = #args

   while i <= nargs do
      i = _parse_arg(options, args, nargs, i)
   end

   return options
end

return {
   arg_opts = arg_opts,
   parse_args = parse_args
}
