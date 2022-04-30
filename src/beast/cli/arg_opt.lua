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

return {
   arg_opts = arg_opts
}
