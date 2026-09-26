-- Locked defaults: ../../../plugin-defaults/markview.nvim.md @ 190bb227c9d3eb4451b81fa16ea3d2efde2d67c5
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

	keys = {
		{ "<leader>ms", "<cmd>Markview splitToggle<cr>", desc = "Toggle Markview split" },
		{ "<leader>m", "<cmd>Markview<cr>", desc = "Toggle Markview preview" },
	},
}
