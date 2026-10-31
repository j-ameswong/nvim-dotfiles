-- Locked defaults: ../../../plugin-defaults/diffview.nvim.md @ 4516612fe98ff56ae0415a259ff6361a89419b0a
return {
	"sindrets/diffview.nvim",
	enabled = true,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewRefresh" },
	opts = {
		enhanced_diff_hl = true,
		view = {
			merge_tool = {
				layout = "diff3_mixed",
			},
		},
	},
	keys = {
		{
			"<leader>gd",
			function()
				if require("diffview.lib").get_current_view() then
					vim.cmd("DiffviewClose")
				else
					vim.cmd("DiffviewOpen")
				end
			end,
			desc = "Toggle diffview of working tree",
		},
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Git history of current file" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Git history of repo" },
		{ "<leader>gh", ":DiffviewFileHistory<cr>", mode = "x", desc = "Git history of selected lines" },
	},
}
