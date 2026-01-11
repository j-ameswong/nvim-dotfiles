return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		ensure_installed = { "lua", "vim", "python", "latex"},
		highlight = { enable = true },
		indent = { enable = true },
	},
}
