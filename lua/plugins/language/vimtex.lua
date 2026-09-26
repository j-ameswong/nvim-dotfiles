-- Locked defaults: ../../../plugin-defaults/vimtex.md @ 16a5609d17a436db7f48046d91747fd6a9d75c74
return {
	"lervag/vimtex",
	lazy = false, -- we don't want to lazy load VimTeX
	-- tag = "v2.15", -- uncomment to pin to a specific release
	init = function()
		-- VimTeX configuration goes here, e.g.
		vim.g.vimtex_view_method = "zathura"
		vim.g.vimtex_view_forward_search_on_start = false
		vim.g.vimtex_compiler_latexmk = {
			aux_dir = "~/.texfiles/",
			out_dir = "~/.texfiles/",
		}
	end,
}
