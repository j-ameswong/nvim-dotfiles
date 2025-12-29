return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	opts = {
		options = {
			-- Ensure the bar hides if the only visible buffer is filtered out
			auto_toggle_bufferline = true,

			custom_filter = function(buf_number, buf_numbers)
				-- 1. Filter out the "netrw" filetype (the default directory viewer)
				if vim.bo[buf_number].filetype == "netrw" then
					return false
				end

				-- 2. Filter out buffers with no name (the [blank] or [No Name] buffers)
				-- CAUTION: This might hide a new 'Untitled' file you just created.
				-- If you only want to hide the directory view, remove this block.
				if vim.fn.bufname(buf_number) == "" then
					return false
				end

				return true
			end,
		},
	},
	keys = {
		-- Existing keys (cycle, pick, etc.)
		{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		-- Close directionally
		{ "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Delete Buffers to the Right" },
		{ "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Delete Buffers to the Left" },
		{ "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Delete Other Buffers" },
		{ "<leader>bp", "<cmd>BufferLinePickClose<cr>", desc = "Delete Buffer (Pick)" },
	},
	lazy = false,
}
