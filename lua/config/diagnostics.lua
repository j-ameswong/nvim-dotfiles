vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  virtual_text = { severity = { min = vim.diagnostic.severity.WARN } },
})
