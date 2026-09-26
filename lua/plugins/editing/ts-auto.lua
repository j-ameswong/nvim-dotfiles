-- Locked defaults: ../../../plugin-defaults/ts-autotag.nvim.md @ 6178353d9003e91eb053d69cf9a4d72e28137daa
return {
	"tronikelis/ts-autotag.nvim",

	keys = {{ "<leader>rn", function()
		-- it returns success status, thus you can fallback like so
		if not require("ts-autotag").rename() then
			vim.lsp.buf.rename()
		end
	end, desc = "Rename tag or LSP symbol" }},
}
