-- Locked defaults: ../../../plugin-defaults/nvim-treesitter.md @ 25a9b06a09ea4e10712bec37e7b7d9f423262b91
return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	-- The main branch uses Neovim's built-in highlighting and install API.
	-- Parsers are installed explicitly with :TSInstall; startup stays offline.
}
