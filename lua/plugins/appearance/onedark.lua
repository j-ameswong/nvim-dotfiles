-- Locked defaults: ../../../plugin-defaults/onedark.nvim.md @ df4792accde9db0043121f32628bcf8e645d9aea
-- return {
--   "catppuccin/nvim",
--   name = "catppuccin",
--   priority = 1000, -- Ensure it loads before other plugins
--   config = function()
--     require("catppuccin").setup({
--       flavour = "mocha", -- Use your preferred flavour
--     })
--
--     -- Load the colorscheme here
--     vim.cmd.colorscheme "catppuccin-nvim"
-- }
  -- end,

return {
  "navarasu/onedark.nvim",
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require('onedark').setup {
      style = 'deep'
    }
    require('onedark').load()
  end
}
