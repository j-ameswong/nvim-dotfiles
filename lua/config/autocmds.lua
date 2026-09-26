vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_treesitter", { clear = true }),
  pattern = { "lua", "vim", "python", "tex", "css", "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
