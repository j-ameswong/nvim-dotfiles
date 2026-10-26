-- Locked defaults: ../../../plugin-defaults/indent-blankline.nvim.md @ f1e186e44d3b7f9ae918008e2c28ce37c6023d2d
-- Locked defaults: ../../../plugin-defaults/mini.indentscope.md @ f75e6e4d560641cbb42e97182819af0175bdfe0e
return {
	{
		"lukas-reineke/indent-blankline.nvim",
		enabled = true,
		main = "ibl",
		opts = {},
	},

	{
		"echasnovski/mini.indentscope",
		enabled = true,
		version = false, -- wait till new 0.7.0 release to put it back on semver
		opts = {
			symbol = "│",
			options = { try_as_border = true },
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},
}
