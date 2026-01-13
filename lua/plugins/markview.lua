-- For `plugins/markview.lua` users.
return {
	"OXY2DEV/markview.nvim",
	lazy = false,

	-- Completion for `blink.cmp`
	dependencies = { "nvim-tree/nvim-web-devicons", "saghen/blink.cmp" },
	opts = {
		preview = { enable = false, icon_provider = "devicons" },
		markdown_inline = {
			strong = {
				enable = true,
			},
		},
	},

	vim.api.nvim_set_keymap(
		"n",
		"<leader>ms",
		"<CMD>Markview splitToggle<CR>",
		{ desc = "Toggles `splitview` for current buffer." }
	),
	vim.api.nvim_set_keymap("n", "<leader>m", "<CMD>Markview<CR>", { desc = "Toggles `markview` previews globally." }),
}
