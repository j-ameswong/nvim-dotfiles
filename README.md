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

Every spec has `enabled = true,` on the line after its name. `:PluginToggle`
flips those flags, and warns when disabling a plugin breaks a spec or config
file that uses it, or when an enabled plugin needs one that is off. Changes
apply after a restart.

After updating plugins with `:Lazy update`, run
`python3 scripts/update-plugin-defaults.py`. The script checks each installed
checkout against `lazy-lock.json` before refreshing snapshots and spec headers.
