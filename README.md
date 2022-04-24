# BEAST

A BEAST of a disassembler for GameBoy.

BEAST is written in Lua.
When run with [LuaJIT](https://luajit.org/), BEAST is super fast.

BEAST will have the capability to automatically add comments to generated assembly code, making understanding it easier.

## Installation

Using [LuaRocks](https://luarocks.org/):

```sh
git clone "https://github.com/rbong/beast.git" beast
cd beast
luarocks make ./beast-dev-1.rockspec
```

## Running

BEAST can't run in CLI mode yet, but you can use the BEAST module:

```lua
local beast = require("beast")

-- Parse a symbols file
local sym = beast.symbol.create_symbols()
beast.symbol.read_symbols(sym, io.open("/path/to/symbols.sym", "rb"))

-- Parse a ROM file
local rom = beast.rom.create_rom()
rom.read_rom(sym, io.open("/path/to/rom.gb", "rb"))

-- Output assembly code
local formatter = beast.format.create_formatter()
beast.format.create_asm(formatter, "/path/to/output/dir", rom, sym)
```

BEAST currently doesn't have an accurate instruction set.

Symbols also aren't currently used while outputting assembly code.
