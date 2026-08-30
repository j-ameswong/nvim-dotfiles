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
  n_prefix = 192,
  n_suffix = 48,
  n_predict = 64,
  t_max_prompt_ms = 300,
  t_max_predict_ms = 700,
  show_info = 0,
}

require("config.keymaps")
require("config.options")
require("config.lazy")
-- require("config.autocmds")
