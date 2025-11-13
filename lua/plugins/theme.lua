return {
  {
    "savq/melange-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme melange]])
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "melange",
    },
  },

  vim.keymap.set("n", "<leader>tb", function()
    vim.opt.background = vim.opt.background:get() == "dark" and "light" or "dark"
  end, { desc = "Toggle background" }),
}
