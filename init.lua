vim.opt.title = true
vim.g.python3_host_prog = '~/.venv/bin/python3'

require("config.keymaps")
require("config.options")
require("config.lazy")
-- require("config.autocmds")
-- Set the color to Cyan (#00ffff) and make it bold
vim.api.nvim_set_hl(0, "MarkviewBoldCustom", { fg = "#00ffff", bold = true })
-- Add these to your init.lua to differentiate your notes
vim.api.nvim_set_hl(0, "MarkviewInlineCode", { fg = "#ff9e64", bg = "#292e42" }) -- Orange text, dark background
vim.api.nvim_set_hl(0, "MarkviewItalic", { fg = "#bb9af7", italic = true })       -- Purple italics
