return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons", -- optional, but recommended
		},
		opts = {
            filesystem = {
                follow_current_file = { enabled = true },
                leave_dirs_open = false,
            },
            bind_to_cwd = true,
			mappings = {
				["Z"] = "expand_all_subnodes",
			},
		},
		keys = {
			{ "<leader>e", ":Neotree toggle<CR>", desc = "Toggle Neo-tree" },
			{ "<leader>b", ":Neotree reveal<CR>", desc = "Force change of cwd" },
		},
		commands = {
			open_visual = function(state)
				local utils = require("neo-tree.utils")
				local renderer = require("neo-tree.ui.renderer")

				-- 1. Get the nodes that are visually selected (Shift+V)
				local selected_nodes = renderer.get_nodes_from_visual_selection(state)

				-- Fallback: If nothing is selected, get the single node under cursor
				if not selected_nodes or #selected_nodes == 0 then
					selected_nodes = { state.tree:get_node() }
				end

				-- 2. Close the tree first so we have the full view
				vim.cmd("Neotree close")

				-- 3. Iterate and open
				for i, node in ipairs(selected_nodes) do
					if node.type == "file" then
						-- "badd" adds the file to the buffer list without displaying it immediately
						vim.cmd("badd " .. node.path)

						-- Optional: If it's the LAST file, actually switch to it
						if i == #selected_nodes then
							vim.cmd("edit " .. node.path)
						end
					end
				end
			end,
		},
		config = function(_, opts)
			require("neo-tree").setup(opts)

			vim.api.nvim_create_autocmd("BufWritePost", { -- Note: "BufLeave" can be a string, doesn't need {}
				callback = function()
					require("neo-tree.sources.manager").refresh("filesystem")
				end,
			})
		end,
		lazy = false, -- neo-tree will lazily load itself
	},
}
