-- Locked defaults: ../../../plugin-defaults/nvim-treesitter.md @ a2f694478be07f89c2d03cc17858a8745a400c4b
return {
	"nvim-treesitter/nvim-treesitter",
	enabled = true,
	lazy = false,
	build = ":TSUpdate",
	-- The main branch uses Neovim's built-in highlighting and install API.
	-- Parsers are installed explicitly with :TSInstall; startup stays offline.
}
