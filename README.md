# BEAST

A BEAST of a disassembler for GameBoy.

BEAST is written in Lua.
When run with [LuaJIT](https://luajit.org/), BEAST is super fast.

BEAST will have the capability to automatically add comments to generated
assembly code, making understanding it easier.

## Installation

Using [LuaRocks](https://luarocks.org/):

```sh
git clone "https://github.com/rbong/beast.git" beast
cd beast
luarocks make ./beast-git-0.rockspec
```

Or, add BEAST to your system paths, ex.:

```sh
export PATH="$PATH:/path/to/beast/bin"
export LUA_PATH="$LUA_PATH;/path/to/beast/src/?.lua"
```

## Running

**CLI**

```bash
beast -s /path/to/symbols.sym /path/to/rom.gb /path/to/output/dir
```

See `beast --help` for more options.

**Module**

```lua
local beast = require("beast")

-- Create default options
local options = beast.cli.Options:new()

-- Parse a symbols file
local sym = beast.symbol.Symbols:new(options)
sym:read_symbols(io.open("/path/to/symbols.sym", "rb"))

-- Parse a ROM file
local rom = beast.rom.Rom:new(options)
rom:read_rom(sym, io.open("/path/to/rom.gb", "rb"))

-- Output assembly code
local formatter = beast.format.Formatter:new(options)
formatter:generate_files("/path/to/output/dir", rom, sym)
```

## Symbol File Syntax

**Defining Labels**

Adds the label `my_label` to the function at bank `0a`, address `4f00`:

```
0a:4f00 my_label
```

Labels will be used throughout the generated assembly code to refer to the address.

**Defining Regions**

Defines a code region at `0a:4f00` that is `f0` bytes long:

```
0a:4f00 .code:f0
```

Defines a data region at `0a:4f00` that is `f0` bytes long:

```
0a:4f00 .data:f0
```

Defines a text region at `0a:4f00` that is `f0` bytes long:

```
0a:4f00 .text:f0
```

Defining regions allows BEAST to more accurately interpret the ROM and generate
assembly code.

**Commenting Code**

Leaves a comment above the code at `0a:4f00`:

```
;; 0a4f00 My comment
```

Generating comments in this way can be useful to leave comments without
distributing the assembly code itself, getting around licensing issues for
ROMs.

**Replacing Operands**

Replaces the operand of the instruction at `0a:4f00` with `MY_CONST`:

```
;; 0a:4f00:op MY_CONST
```

Any [RGBASM-compatible code](https://rgbds.gbdev.io/docs/v0.5.0/rgbasm.5/) is supported.

This is useful for improving readability of the generated assembly code by
using constants and math rather than hardcoded values.

**Replacing Code**

Replaces `f0` bytes of code at `0a:4f00` with `MY_MACRO`:

```
;; 0a:4f00:replace:f0 MY_MACRO
```

Any [RGBASM-compatible code](https://rgbds.gbdev.io/docs/v0.5.0/rgbasm.5/) is supported.

This is useful for improving readability of the generated assembly code by
using macros rather than repeating code.
