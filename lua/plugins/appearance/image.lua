-- Locked defaults: ../../../plugin-defaults/image.nvim.md @ 365e2ace0f619164ae6fd2f6f1d2807775dd6849
return {
    "3rd/image.nvim",
    enabled = true,
    build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
    opts = {
        processor = "magick_cli",
    }
}
