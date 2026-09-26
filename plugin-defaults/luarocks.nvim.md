# luarocks.nvim defaults and configuration source

Commit: `1db9093915eb16ba2473cfb8d343ace5ee04130a`

These are the upstream configuration sources at the locked commit. Defaults defined in code are reproduced verbatim; documentation is included for plugins whose settings are not expressed as one Lua table.

## README.md

````text
<div align="center">

# luarocks.nvim

</div>

`luarocks.nvim` is a Neovim plugin designed to streamline the installation of luarocks packages directly within Neovim. It simplifies the process of managing Lua dependencies, ensuring a hassle-free experience for Neovim users.

## Requirements

- Neovim `0.9` or greater.
- The `git` CLI tool.
- Lua 5.1 or LuaJIT installed on your system and available in your system's `PATH`.

  **On unix systems**, this is as simple as using your system package manager (`brew`, `pacman`, `apt` etc.).
  Just make sure that you're installing the 5.1 or JIT version of lua!
  Here's a list of known package names for various package managers (choose the one your distro uses):
  - brew (MacOS): `brew install luajit`
  - apt: `sudo apt install liblua5.1-0-dev`
  - dnf: `sudo dnf install compat-lua-devel-5.1.5`
  - pacman: `sudo pacman -Syu lua51` or `sudo pacman -Syu luajit`

  **On Windows systems**, it's recommended to use an all-in-one installer like https://github.com/rjpcomputing/luaforwindows.
  Be sure to restart your terminal after installing Lua for the `PATH` to be updated!

## Usage

### Lazy.nvim Integration

For users employing the Lazy.nvim plugin manager, `luarocks.nvim` can be added to your configuration with the following code:

```lua
{
  "vhyrro/luarocks.nvim",
  priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
  config = true,
}
```

Upon installing, an automatic build step will be invoked by `lazy.nvim` in an attempt to compile a local luarocks installation on your machine.
If you're having issues with this, be sure to manually run `:Lazy build luarocks.nvim`!

Generally, other plugins which rely on `luarocks.nvim` as their dependency manager perform automatic
dependency installation in their `build.lua`s, so you don't even have to touch any options yourself!
Just set up this plugin and the rest should be automatic.

### Installing a Rock List

To install a set of rocks (with the ability to add version constraints) use the following configuration instead:

```lua
{
  "vhyrro/luarocks.nvim",
  priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
  opts = {
    rocks = { "fzy", "pathlib.nvim ~> 1.0" }, -- specifies a list of rocks to install
    -- luarocks_build_args = { "--with-lua=/my/path" }, -- extra options to pass to luarocks's configuration script
  },
}
```

The latest version of a rock will be pulled if the version constraint is not provided.

### Other Plugin Managers

For users utilizing other plugin managers, manual setup is required. Use the following code to initialize `luarocks.nvim`:

```lua
require("luarocks-nvim").setup()
```

Not only this, you will also need to set up a manual build trigger. This is supported by most
plugin managers like `packer`/`pckr` and `vim-plug`. See [manual build trigger](#manual-build-trigger)
for more info.

## Build Process

The `luarocks.nvim` plugin includes a build process to ensure proper functionality. The build process involves the following steps:

1. Checking for the existence of `lua` and its respective version as well as `git`.
2. Cloning the `luarocks/luarocks` repository at the lowest possible depth.
3. Compiling `luarocks` into a `.rocks` directory directly in this plugin's root.
   On Windows the install process may prompt for administrative permissions.

### Manual Build Trigger

You can manually trigger the build process using the following command inside the plugin root:

```bash
nvim -l build.lua
```

Executing this command initiates the complete build process, ensuring that all dependencies are properly installed. This manual trigger can be useful in scenarios where you want to ensure a fresh installation or troubleshoot any issues related to the build process.

Please note that the build process is automatically invoked during the setup phase, so manual triggering may be unnecessary in most cases.

````

## UNLICENSE

```text
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org>

```
