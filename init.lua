vim.opt.title = true
vim.g.python3_host_prog = '~/.venv/bin/python3'

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN }
  },
})

vim.lsp.config('solargraph', {
  cmd = { 'bundle', 'exec', 'solargraph', 'stdio' },
  filetypes = { 'ruby' },
  root_markers = { 'Gemfile', '.git' },
  settings = {
    solargraph = {
      diagnostics = true,
      completion = true,
    }
  }
})

vim.lsp.enable('solargraph')

require("config.keymaps")
require("config.options")
require("config.lazy")
-- require("config.autocmds")
