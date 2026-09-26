-- Locked defaults: ../../../plugin-defaults/nvim-spectre.md @ 72f56f7585903cd7bf92c665351aa585e150af0f
return {
	"nvim-pack/nvim-spectre",
	keys = {
		-- Search and replace
		{
            "<leader>sr",
            '<cmd>lua require("spectre").toggle()<CR>',
			desc = "Toggle Spectre",
		},
		{
			"<leader>rw",
			'<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
			desc = "Search current word",
		},
		{
			"<leader>rw",
			'<esc><cmd>lua require("spectre").open_visual()<CR>',
			mode = "v",
			desc = "Search current word",
		},
		{
			"<leader>rf",
			'<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
			desc = "Search on current file",
		},
	},
}
