rockspec_format = "3.0"

package = "beast"

version = "dev-1"

source = {
   url = "https://github.com/rbong/beast"
}

description = {
   homepage = "https://github.com/rbong/beast",
   license = "MIT"
}

dependencies = {}

test_dependencies = {
   "busted ~> 2.0.0-1",
   "luacheck ~> 0.26.0-1"
}

build = {
   type = "builtin",
   modules = {
      ["beast"] = "src/beast/init.lua",
      ["beast/cli"] = "src/beast/cli/init.lua",
      ["beast/cli/arg"] = "src/beast/cli/arg.lua",
      ["beast/cli/arg_opt"] = "src/beast/cli/arg_opt.lua",
      ["beast/format"] = "src/beast/format/init.lua",
      ["beast/format/format"] = "src/beast/format/format.lua",
      ["beast/option"] = "src/beast/option/init.lua",
      ["beast/option/option"] = "src/beast/option/option.lua",
      ["beast/rom"] = "src/beast/rom/init.lua",
      ["beast/rom/bank"] = "src/beast/rom/bank.lua",
      ["beast/rom/instruction"] = "src/beast/rom/instruction.lua",
      ["beast/rom/operand"] = "src/beast/rom/operand.lua",
      ["beast/rom/rom"] = "src/beast/rom/rom.lua",
      ["beast/symbol"] = "src/beast/symbol/init.lua",
      ["beast/symbol/definition"] = "src/beast/symbol/definition.lua",
      ["beast/symbol/line_reader"] = "src/beast/symbol/line_reader.lua",
      ["beast/symbol/memory_area"] = "src/beast/symbol/memory_area.lua",
      ["beast/symbol/symbol"] = "src/beast/symbol/symbol.lua"
   },
   install = {
      bin = {
         ['beast'] = 'bin/beast'
      }
   }
}

test = {
   type = "busted"
}
