-- Locked defaults: ../../../plugin-defaults/mason.nvim.md @ 2a6940af80375532e5e9e7c1f2fc6319a1b7a69d
-- Locked defaults: ../../../plugin-defaults/mason-lspconfig.nvim.md @ a338f44149f5673882c32629697d67b0c0547aec
-- Locked defaults: ../../../plugin-defaults/nvim-java.md @ db5536b4cb3da153084e50016596fd0e3a319aae
return {
	{
		"mason-org/mason.nvim",
		enabled = true,
		opts = {},
	},
	{
		"nvim-java/nvim-java",
		enabled = true,
		config = function()
			require("java").setup()
			vim.lsp.enable("jdtls")
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		enabled = true,
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
