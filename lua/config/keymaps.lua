vim.g.mapleader = " "
vim.keymap.set("n", "<Esc>", vim.cmd.nohl)

-- Keep centered
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "=ap", "ma=ap'a")
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>")

-- Open the error message in a floating window (like hovering)
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show Line Diagnostics" })

-- Jump to the previous or next error
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

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

vim.keymap.set("n", "<leader>f", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
