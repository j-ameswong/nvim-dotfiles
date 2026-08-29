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

vim.g.llama_config = {
  endpoint_fim = "http://127.0.0.1:8012/infill",
  n_prefix = 256,
  n_suffix = 64,
  n_predict = 128,
  t_max_prompt_ms = 500,
  t_max_predict_ms = 1000,
  show_info = 0,
}

require("config.keymaps")
require("config.options")
require("config.lazy")
-- require("config.autocmds")
