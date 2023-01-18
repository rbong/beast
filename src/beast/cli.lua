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

local function print_usage()
    print([[Usage: beast [arguments] <rom path> <output directory>

Disassembles the GameBoy ROM into assembly files at the output directory.

Arguments:
  -s, --symbols <symbols path>  Load symbols from this file. Symbols can be
                                used to add labels and modify the output.
  -nc, --no-code-detection      Do not automatically detect code regions based
                                on call/jump locations.
  -nl, --no-auto-labels         Do not automatically generate labels for
                                call/jump locations.
  -h, --help                    Display this help and exit.
  -v, --version                 Display version and exit.]])
end

local function print_version()
    print("git-0")
end

local Options = {}

Options.new = function(self)
    local options = {}

    setmetatable(options, self)
    self.__index = self

    for _, arg_opt in pairs(arg_opts) do
        options[arg_opt.opt_name] = arg_opt.default
    end

    for _, arg_opt in pairs(positional_arg_opts) do
        options[arg_opt.opt_name] = arg_opt.default
    end

    return options
end

Options.is_missing_required_opt = function(self, arg_opt)
    return arg_opt.required and not self[arg_opt.opt_name]
end

local ArgParser = {}

ArgParser.new = function(self, args, options)
    local arg_parser = {
        args = args,
        options = options,
        nargs = #args,
        arg_index = 1,
        pos_arg_opt_index = 1,
    }

    setmetatable(arg_parser, self)
    self.__index = self

    return arg_parser
end

ArgParser.has_args = function(self)
    return self.arg_index <= self.nargs
end

ArgParser.parse_positional_arg = function(self)
    local arg = self.args[self.arg_index]
    local arg_opt = positional_arg_opts[self.pos_arg_opt_index]

    if not arg_opt then
        -- TODO: better error handling
        error(string.format("Unexpected positional argument: %s", arg))
    end

    self.options[arg_opt.opt_name] = arg
    self.pos_arg_opt_index = self.pos_arg_opt_index + 1
    self.arg_index = self.arg_index + 1
end

ArgParser.parse_arg = function(self)
    local args = self.args
    local options = self.options
    local nargs = self.nargs

    local arg = args[self.arg_index]

    local _, match_end, name, equals, value = arg:find("^(-[^=]+)(=?)(.*)")

    -- Ignore remaining args
    if name == "--" and equals == "" then
        self.arg_index = self.nargs + 1
        return
    end

    -- Handle positional args
    if not match_end then
        self:parse_positional_arg()
        return
    end

    -- Count arg as parsed
    self.arg_index = self.arg_index + 1

    -- Get arg option
    local arg_opt = arg_opts[name]
    if not arg_opt then
        -- TODO: print usage
        error(string.format("Unrecognized argument: '%s'", name))
    end

    -- Handle special arguments
    if arg_opt.opt_name == "help" then
        print_usage()
        os.exit(0)
    end
    if arg_opt.opt_name == "version" then
        print_version()
        os.exit(0)
    end

    -- Handle flags
    if arg_opt.flag_value ~= nil then
        options[arg_opt.opt_name] = arg_opt.flag_value
        return
    end

    -- Get value
    if equals == "" then
        if self.arg_index > nargs then
            error(string.format("Reached end of arguments before reaching value for: '%s'", name))
        end

        value = args[self.arg_index]

        -- Count value as parsed
        self.arg_index = self.arg_index + 1
    end

    -- Set option
    options[arg_opt.opt_name] = value

    return
end

ArgParser.verify_args = function(self)
    local options = self.options

    for _, arg_opt in pairs(arg_opts) do
        if options:is_missing_required_opt(arg_opt) then
            -- TODO: better error handling
            error(string.format("Missing required argument: %s", arg_opt.long_arg or arg_opt.short_arg))
        end
    end

    for _, arg_opt in pairs(positional_arg_opts) do
        if options:is_missing_required_opt(arg_opt) then
            -- TODO: better error handling
            error(string.format("Missing required positional argument: %s", arg_opt.opt_name))
        end
    end
end

local function parse_args(args)
    local options = Options:new()
    local arg_parser = ArgParser:new(args, options)

    while arg_parser:has_args() do
        arg_parser:parse_arg()
    end

    arg_parser:verify_args()

    return options
end

return {
    Options = Options,
    ArgParser = ArgParser,
    arg_opts = arg_opts,
    positional_arg_opts = positional_arg_opts,
    parse_args = parse_args,
}
