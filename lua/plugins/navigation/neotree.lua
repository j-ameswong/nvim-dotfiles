-- Locked defaults: ../../../plugin-defaults/neo-tree.nvim.md @ 1a14083046d96e88e361d1da00761c40d45012f3
-- Persisted Neo-tree width: remembers the width you last resized the tree to,
-- per working directory, across toggles and across nvim restarts.
local width_file = vim.fn.stdpath("data") .. "/neo-tree-width.json"
local default_width = 30

-- widths[git root] = columns, loaded from disk; dirty holds the roots changed in
-- this session, so a merge on write doesn't clobber other nvim instances.
local widths = {}
local dirty = {}

-- Key on the git root containing cwd, so every subdirectory of a project shares
-- one width. Falls back to cwd outside a repo. Cached: WinResized fires often.
local root_cache = {}

local function cwd_key()
	local cwd = vim.fs.normalize(vim.fn.getcwd())
	local cached = root_cache[cwd]
	if cached then
		return cached
	end
	-- matches both a .git directory and the .git file used by worktrees/submodules
	local git = vim.fs.find(".git", { path = cwd, upward = true, limit = 1 })[1]
	local root = git and vim.fs.normalize(vim.fs.dirname(git)) or cwd
	root_cache[cwd] = root
	return root
end

local function read_file()
	local f = io.open(width_file, "r")
	if not f then
		return {}
	end
	local contents = f:read("*a")
	f:close()
	local ok, decoded = pcall(vim.json.decode, contents or "")
	return (ok and type(decoded) == "table") and decoded or {}
end

widths = read_file()

local function current_width()
	local w = widths[cwd_key()]
	return (type(w) == "number" and w > 0) and w or default_width
end

local function remember(w)
	if type(w) == "number" and w > 0 then
		local key = cwd_key()
		widths[key] = w
		dirty[key] = true
	end
end

-- Grab the width of the neo-tree window (if one is open) in the current tabpage.
local function capture_width()
	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local bufnr = vim.api.nvim_win_get_buf(winid)
		if vim.bo[bufnr].filetype == "neo-tree" then
			remember(vim.api.nvim_win_get_width(winid))
			return
		end
	end
end

local function persist_width()
	if vim.tbl_isempty(dirty) then
		return
	end
	-- merge over whatever is on disk, and drop directories that no longer exist
	local on_disk = read_file()
	for key in pairs(dirty) do
		on_disk[key] = widths[key]
	end
	for key in pairs(on_disk) do
		if not vim.uv.fs_stat(key) then
			on_disk[key] = nil
		end
	end
	local f = io.open(width_file, "w")
	if f then
		f:write(vim.json.encode(on_disk))
		f:close()
		dirty = {}
	end
end

return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		enabled = true,
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons", -- optional, but recommended
		},
		opts = {
			filesystem = {
				follow_current_file = { enabled = true },
				leave_dirs_open = true,
			},
			bind_to_cwd = true,
			window = {
				-- resolved every time the tree opens, so it picks up the remembered size
				width = function()
					return current_width()
				end,
				mappings = {
					["Z"] = "expand_all_subnodes",
					["O"] = "open_visual",
				},
			},
			event_handlers = {
				{
					event = "neo_tree_window_before_close",
					handler = function(args)
						if args.winid and vim.api.nvim_win_is_valid(args.winid) then
							remember(vim.api.nvim_win_get_width(args.winid))
						end
						persist_width()
					end,
				},
			},
			commands = {
				open_visual = function(state)
					local renderer = require("neo-tree.ui.renderer")
					local selected_nodes = renderer.get_nodes_from_visual_selection(state)
					if not selected_nodes or #selected_nodes == 0 then
						selected_nodes = { state.tree:get_node() }
					end
					vim.cmd("Neotree close")
					local last_file
					for _, node in ipairs(selected_nodes) do
						if node.type == "file" then
							vim.cmd("badd " .. vim.fn.fnameescape(node.path))
							last_file = node.path
						end
					end
					if last_file then
						vim.cmd("edit " .. vim.fn.fnameescape(last_file))
					end
				end,
			},
		},
		keys = {
			{ "<leader>e", ":Neotree toggle<CR>", desc = "Toggle Neo-tree" },
			{ "<leader>bb", ":Neotree reveal<CR>", desc = "Force change of cwd" },
		},
		config = function(_, opts)
			require("neo-tree").setup(opts)

			vim.api.nvim_create_autocmd("BufWritePost", { -- Note: "BufLeave" can be a string, doesn't need {}
				callback = function()
					require("neo-tree.sources.manager").refresh("filesystem")
				end,
			})

			-- Track manual resizes (mouse drag, <C-w>>, :vertical resize) so the
			-- width survives even when neo-tree's close event doesn't fire.
			vim.api.nvim_create_autocmd({ "WinResized", "WinLeave" }, {
				callback = capture_width,
			})

			vim.api.nvim_create_autocmd("VimLeavePre", {
				callback = function()
					capture_width()
					persist_width()
				end,
			})
		end,
		lazy = false, -- neo-tree will lazily load itself
	},
}
