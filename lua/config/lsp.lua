vim.g.python3_host_prog = vim.fn.expand("~/.venv/bin/python3")

vim.lsp.config("solargraph", {
  cmd = { "bundle", "exec", "solargraph", "stdio" },
  filetypes = { "ruby" },
  root_markers = { "Gemfile", ".git" },
  settings = { solargraph = { diagnostics = true, completion = true } },
})
vim.lsp.enable("solargraph")
