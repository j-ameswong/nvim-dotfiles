-- Locked defaults: ../../../plugin-defaults/nvim-surround.md @ 1098d7b3c34adcfa7feb3289ee434529abd4afd1
return {
    "kylechui/nvim-surround",
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    opts = {
        keymaps = {
            visual = "<C-g>",
            visual_line = "<C-v>",
        }
    }
}
