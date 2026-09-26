# Neovim configuration

`init.lua` sets leaders and loads editor options, diagnostics, language servers,
keymaps, filetype autocommands, then lazy.nvim. Plugin specs live in
`lua/plugins/` by purpose: `appearance`, `editing`, `git`, `infrastructure`,
`language`, and `navigation`. Filetype-local settings live in `ftplugin/`.

Each plugin spec starts with the locked commit and the path to its complete
upstream configuration source snapshot in `plugin-defaults/`. The snapshots
include the default tables and the surrounding source needed to understand
computed defaults. Plugins configured through Vim globals or commands have
their upstream help text instead. These files are references; edit the spec's
`opts`, `init`, or `config` to change behaviour.

After updating plugins with `:Lazy update`, run
`python3 scripts/update-plugin-defaults.py`. The script checks each installed
checkout against `lazy-lock.json` before refreshing snapshots and spec headers.

## Audit notes

- `lua/ftplugin/` was not an automatic runtime location. Its scripts now live
  in `ftplugin/`.
- The installed Tree-sitter main branch uses `install()` and Neovim's
  `vim.treesitter.start()`, so the previous `ensure_installed` and `highlight`
  options were ineffective. Parsers remain an explicit install step; the
  `FileType` autocmd enables highlighting for the configured languages when a
  parser exists.
- Three specs used mapping calls as table entries. The maps now use lazy.nvim's
  `keys` field, so loading and descriptions work as intended.
- Neo-tree's custom command and mapping were outside their documented option
  locations. They now live in `opts.commands` and `opts.window.mappings`.
- `prettier.nvim` was not set up and its `null-ls` dependency was absent. Its
  unused spec was removed; Neoformat remains the manual formatter on
  `<leader><leader>`.
- Blink listed Avante completion sources, but Avante was not installed. Those
  sources and their compatibility dependency were removed.
- `python3_host_prog` now expands `~` to an absolute path.
- `llama.vim` overrides are applied in the plugin `init` hook and merged with
  existing defaults, so reloading lazy.nvim specs cannot erase required keys.
- FzfLua and Neoformat now load when their commands are used, which avoids
  starting them on every launch.

External tool check on this machine found `google-java-format`, `zathura`, and
`latexmk` absent from `PATH`. The Java Neoformat recipe and VimTeX viewer or
compiler need those programs installed or their commands adjusted. The Python
host, `bundle`, `solargraph`, `fzf`, `rg`, and `magick` were found.

The startup check under the restricted workspace can report errors from
plugins that open sockets, write outside this directory, or query a terminal.
Syntax checks and an isolated filetype-loading check pass.
