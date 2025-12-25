vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", vim.cmd.Neotree)
vim.keymap.set("n", "<leader>E", "<cmd>Neotree filesystem reveal<CR>")
vim.keymap.set("n", "<Esc>", vim.cmd.nohl)

-- Terminal
vim.keymap.set("n", "<C-/>", vim.cmd.ToggleTerm)
vim.keymap.set("t", "<C-/>", [[<C-\><C-n>]])

-- Keep centered
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "=ap", "ma=ap'a")
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>")

-- Search and replace
vim.keymap.set("n", "<leader>R", '<cmd>lua require("spectre").toggle()<CR>', { desc = "Toggle Spectre" })

vim.keymap.set(
	"n",
	"<leader>rw",
	'<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
	{ desc = "Search current word" }
)
vim.keymap.set(
	"v",
	"<leader>rw",
	'<esc><cmd>lua require("spectre").open_visual()<CR>',
	{ desc = "Search current word" }
)
vim.keymap.set(
	"n",
	"<leader>rf",
	'<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
	{ desc = "Search on current file" }
)

-- Formatting
vim.keymap.set("n", "<leader><leader>", "<cmd>Neoformat<CR>")

-- Fzf
vim.keymap.set("n", "<leader>sf", "<cmd>FzfLua files<CR>") -- search files
vim.keymap.set("n", "<leader>sF", "<cmd>FzfLua files cwd=~/<CR>") -- search all files
vim.keymap.set("n", "<leader>sg", "<cmd>FzfLua live_grep<CR>") -- search text

-- Move to window using the <ctrl> hjkl keys
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Swap selection
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Replace without copying
vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")

vim.keymap.set("n", "<leader>f", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
