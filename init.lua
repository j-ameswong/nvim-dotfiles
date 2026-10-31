vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.diagnostics")
require("config.lsp")
require("config.keymaps")
require("config.autocmds")
-- before lazy, so :PluginToggle still works when a plugin fails to load
require("config.plugin_toggle")
require("config.lazy")
