-- Locked defaults: ../../../plugin-defaults/markview.nvim.md @ ecc5a8867daa1856f8bcc5fdbceca8f5a5ce5f5d
-- For `plugins/markview.lua` users.
return {
	"OXY2DEV/markview.nvim",
	enabled = true,
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

	keys = {
		{ "<leader>ms", "<cmd>Markview splitToggle<cr>", desc = "Toggle Markview split" },
		{ "<leader>m", "<cmd>Markview<cr>", desc = "Toggle Markview preview" },
	},
}
