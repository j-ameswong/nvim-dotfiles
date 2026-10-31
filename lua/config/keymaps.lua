vim.keymap.set("n", "<C-Esc>", vim.cmd.nohl)
vim.keymap.set("n", "<Esc>", function()
  vim.cmd.nohlsearch()
  if vim.fn.exists("*llama#inst_cancel") == 1 then
    vim.fn["llama#inst_cancel"]()
  end
end, { desc = "Clear search highlight and cancel llama instruction" })

-- Lsp
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })

-- Keep centered
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "=ap", "ma=ap'a")
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>")

-- Open the error message in a floating window (like hovering)
vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, { desc = "Show Code Info" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Show Code Actions" })
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show Line Diagnostics" })

-- Jump to the previous or next error
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

-- Formatting
vim.keymap.set("n", "<leader><leader>", "<cmd>Neoformat<CR>")

-- Private copy/paste: register a never touches the system clipboard.
vim.keymap.set({ "n", "x" }, "<leader>y", '"ay', { desc = "Yank to private register" })
vim.keymap.set("n", "<leader>p", '"ap', { desc = "Paste from private register" })
vim.keymap.set("n", "<leader>P", '"aP', { desc = "Paste private register before cursor" })

-- Fzf
vim.keymap.set("n", "<leader>sf", "<cmd>FzfLua files<CR>") -- search files
vim.keymap.set("n", "<leader>sF", "<cmd>FzfLua files cwd=~/<CR>") -- search all files
vim.keymap.set("n", "<leader>sg", "<cmd>FzfLua live_grep<CR>") -- search text
vim.keymap.set("n", "<leader>sk", "<cmd>FzfLua keymaps<CR>") -- search text

-- Move to window using the <ctrl> hjkl keys
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Swap selection
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Move text after to line below
vim.keymap.set("n", "K", "i<CR><Esc>k$")

-- Replace without copying
vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set("n", "<leader>f", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

local function llama_auto_fim_on()
  local cfg = vim.g.llama_config
  local v = cfg and cfg.auto_fim
  return v ~= nil and v ~= false and v ~= 0
end

vim.keymap.set("n", "<leader>llt", function()
  if vim.fn.exists(":LlamaToggleAutoFim") ~= 2 then
    vim.notify("llama.vim not loaded", vim.log.levels.WARN)
    return
  end

  local before = llama_auto_fim_on()
  vim.cmd("LlamaToggleAutoFim")
  local after = llama_auto_fim_on()

  if after == before then
    vim.notify("llama: auto FIM unchanged, run :LlamaEnable first", vim.log.levels.WARN)
  else
    vim.notify("llama: auto FIM " .. (after and "on" or "off"))
  end
end, { desc = "Toggle llama auto FIM" })
