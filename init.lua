vim.opt.title = true
vim.g.python3_host_prog = '~/.venv/bin/python3'

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN }
  },
})

require("config.keymaps")
require("config.options")
require("config.lazy")
-- require("config.autocmds")
