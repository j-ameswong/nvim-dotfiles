return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000, -- Ensure it loads before other plugins
  config = function()
    require("catppuccin").setup({
      flavour = "mocha", -- Use your preferred flavour
    })
    
    -- Load the colorscheme here
    vim.cmd.colorscheme "catppuccin"
  end,
}
