return {
	-- amongst your other plugins
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = {--[[ things you want to change go here]]
			start_in_insert = true,
		},
		keys = {
			vim.keymap.set({"n", "t"}, "<C-/>", vim.cmd.ToggleTerm),
			-- vim.keymap.set("t", "<C-/>", vim.cmd.ToggleTerm),
		},
        lazy = false,
	},
}
