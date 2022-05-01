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
      ["beast"] = "src/beast.lua",
      ["beast/cli"] = "src/beast/cli.lua",
      ["beast/format"] = "src/beast/format.lua",
      ["beast/option"] = "src/beast/option.lua",
      ["beast/rom"] = "src/beast/rom.lua",
      ["beast/instruction"] = "src/beast/instruction.lua",
      ["beast/symbol"] = "src/beast/symbol.lua"
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
