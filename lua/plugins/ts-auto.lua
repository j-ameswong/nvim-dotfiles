return {
	"tronikelis/ts-autotag.nvim",

	vim.keymap.set("n", "<leader>rn", function()
		-- it returns success status, thus you can fallback like so
		if not require("ts-autotag").rename() then
			vim.lsp.buf.rename()
		end
	end),
}
