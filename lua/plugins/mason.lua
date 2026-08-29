return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"nvim-java/nvim-java",
		config = function()
			require("java").setup()
			vim.lsp.enable("jdtls")
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = { "lua_ls" },
			-- mason-lspconfig v2 auto-enables every installed Mason server.
			-- kotlin-language-server (fwcd) crashes on JDK 25/26 and is superseded
			-- by kotlin-lsp, which kotlin.nvim drives itself -- keep both out.
			automatic_enable = {
				exclude = { "kotlin_language_server", "kotlin_lsp" },
			},
		},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
	},
}
