local arg_opts = {}
local positional_arg_opts = {}

-- TODO: verify paths

local function add_arg_opt(short_arg, long_arg, arg_opt)
    arg_opt = arg_opt or {}

    arg_opt.positional = false
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

local function add_positional_arg_opt(arg_opt)
    arg_opt.positional = true
    table.insert(positional_arg_opts, arg_opt)
end

add_arg_opt("-h", "--help")
add_arg_opt("-v", "--version")

-- TODO: default to rom_path.sym with or without ROM extension
add_arg_opt("-s", "--symbols", {
    opt_name = "symbols_path",
})

add_arg_opt("-nd", "--no-code-detection", {
    opt_name = "no_code_detection",
    flag_value = true,
})
add_arg_opt("-nl", "--no-auto-labels", {
    opt_name = "no_auto_labels",
    flag_value = true,
})

add_positional_arg_opt({
    opt_name = "rom_path",
    required = true,
})
add_positional_arg_opt({
    opt_name = "out_path",
    default = "disassembly",
})

local set_default_arg_opt

local function create_options()
    local options = {}

    for _, arg_opt in pairs(arg_opts) do
        set_default_arg_opt(options, arg_opt)
    end

    for _, arg_opt in pairs(positional_arg_opts) do
        set_default_arg_opt(options, arg_opt)
    end

    return options
end

function set_default_arg_opt(options, arg_opt)
    options[arg_opt.opt_name] = arg_opt.default
end

local function is_missing_required_opt(options, arg_opt)
    return arg_opt.required and not options[arg_opt.opt_name]
end

local function create_arg_parser(args, options)
    return {
        args = args,
        options = options,
        nargs = #args,
        arg_index = 1,
        pos_arg_opt_index = 1,
    }
end

local function parse_positional_arg(arg_parser)
    local arg = arg_parser.args[arg_parser.arg_index]
    local arg_opt = positional_arg_opts[arg_parser.pos_arg_opt_index]

    if not arg_opt then
        -- TODO: better error handling
        error(string.format("Unexpected positional argument: %s", arg))
    end

    arg_parser.options[arg_opt.opt_name] = arg
    arg_parser.pos_arg_opt_index = arg_parser.pos_arg_opt_index + 1
    arg_parser.arg_index = arg_parser.arg_index + 1
end

local function parse_arg(arg_parser)
    local args = arg_parser.args
    local options = arg_parser.options
    local nargs = arg_parser.nargs

    local arg = args[arg_parser.arg_index]

    local _, match_end, name, equals, value = arg:find("^(-[^=]+)(=?)(.*)")

    -- Ignore remaining args
    if name == "--" and equals == "" then
        arg_parser.arg_index = arg_parser.nargs + 1
        return
    end

    -- Handle positional args
    if not match_end then
        parse_positional_arg(arg_parser)
        return
    end

    -- Count arg as parsed
    arg_parser.arg_index = arg_parser.arg_index + 1

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
        return
    end

    -- Get value
    if equals == "" then
        if arg_parser.arg_index > nargs then
            error(string.format("Reached end of arguments before reaching value for: '%s'", name))
        end

        value = args[arg_parser.arg_index]

        -- Count value as parsed
        arg_parser.arg_index = arg_parser.arg_index + 1
    end

    -- Set option
    options[arg_opt.opt_name] = value

    return
end

local function verify_args(arg_parser)
    local options = arg_parser.options

    for _, arg_opt in pairs(arg_opts) do
        if is_missing_required_opt(options, arg_opt) then
            -- TODO: better error handling
            error(string.format("Missing required argument: %s", arg_opt.long_arg or arg_opt.short_arg))
        end
    end

    for _, arg_opt in pairs(positional_arg_opts) do
        if is_missing_required_opt(options, arg_opt) then
            -- TODO: better error handling
            error(string.format("Missing required positional argument: %s", arg_opt.opt_name))
        end
    end
end

local function parse_args(args)
    local options = create_options()
    local arg_parser = create_arg_parser(args, options)

    while arg_parser.arg_index <= arg_parser.nargs do
        parse_arg(arg_parser)
    end

    verify_args(arg_parser)

    return options
end

return {
    create_options = create_options,
    arg_opts = arg_opts,
    positional_arg_opts = positional_arg_opts,
    parse_args = parse_args,
}
