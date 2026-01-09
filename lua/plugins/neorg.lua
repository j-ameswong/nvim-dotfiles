return {
    "nvim-neorg/neorg",
    lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    dependencies = { "nvim-neorg/tree-sitter-norg" },
    -- version = "*", -- Pin Neorg to the latest stable release
    version = false,
    config = true,
    opts = {
        load = {
            ["core.defaults"] = {},
            ["core.concealer"] = {},
        }
    }
}
