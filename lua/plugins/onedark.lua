-- Using Lazy
return {
  "navarasu/onedark.nvim",
  version = "v0.1.0", -- Pin to legacy version
  priority = 1000,
  config = function()
    require('onedark').setup {
      style = 'darker',
      transparent = true,
    }
    require('onedark').load()
  end
}
