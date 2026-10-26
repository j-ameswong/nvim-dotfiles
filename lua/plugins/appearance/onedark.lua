-- Locked defaults: ../../../plugin-defaults/onedark.nvim.md @ df4792accde9db0043121f32628bcf8e645d9aea
-- return {
--   "catppuccin/nvim",
--   name = "catppuccin",
--   priority = 1000, -- Ensure it loads before other plugins
--   config = function()
--     require("catppuccin").setup({
--       flavour = "mocha", -- Use your preferred flavour
--     })
--
--     -- Load the colorscheme here
--     vim.cmd.colorscheme "catppuccin-nvim"
-- }
  -- end,

-- onedark recoloured to match opencode's default TUI theme
-- (sst/opencode packages/tui/src/theme/assets/opencode.json + packages/theme/src/tui/syntax.ts)
local opencode_colors = {
  black = "#050505",
  bg0 = "#0a0a0a",
  bg1 = "#141414",
  bg2 = "#1e1e1e",
  bg3 = "#2a2a2a",
  bg_d = "#0f0f0f",
  bg_blue = "#5c9cf5",
  bg_yellow = "#fab283",
  fg = "#eeeeee",
  purple = "#9d7cd8",
  green = "#7fd88f",
  orange = "#f5a742",
  blue = "#5c9cf5",
  yellow = "#e5c07b",
  cyan = "#56b6c2",
  red = "#e06c75",
  grey = "#808080",
  light_grey = "#a0a0a0",
  dark_cyan = "#2b6f77",
  dark_red = "#c53b53",
  dark_yellow = "#93691d",
  dark_purple = "#6a4fa0",
  diff_add = "#20303b",
  diff_delete = "#37222c",
  diff_change = "#1c2a3b",
  diff_text = "#2c4a6b",
  peach = "#fab283",
}

local syntax = {
  ["@keyword"] = { fg = "$purple", fmt = "italic" },
  ["@keyword.return"] = { fg = "$purple", fmt = "italic" },
  ["@keyword.conditional"] = { fg = "$purple", fmt = "italic" },
  ["@keyword.repeat"] = { fg = "$purple", fmt = "italic" },
  ["@keyword.import"] = { fg = "$purple", fmt = "NONE" },
  ["@keyword.function"] = { fg = "$peach", fmt = "NONE" },
  ["@keyword.type"] = { fg = "$yellow", fmt = "bold,italic" },
  ["@keyword.operator"] = { fg = "$cyan", fmt = "NONE" },
  ["@operator"] = { fg = "$cyan" },
  ["@punctuation.delimiter"] = { fg = "$cyan" },
  ["@punctuation.bracket"] = { fg = "$fg" },
  ["@punctuation.special"] = { fg = "$cyan" },
  ["@variable"] = { fg = "$red" },
  ["@variable.parameter"] = { fg = "$red" },
  ["@variable.member"] = { fg = "$peach" },
  ["@variable.builtin"] = { fg = "$red" },
  ["@property"] = { fg = "$red" },
  ["@function"] = { fg = "$peach" },
  ["@function.method"] = { fg = "$peach" },
  ["@function.call"] = { fg = "$red" },
  ["@function.method.call"] = { fg = "$red" },
  ["@function.builtin"] = { fg = "$red" },
  ["@constructor"] = { fg = "$peach", fmt = "NONE" },
  ["@type"] = { fg = "$yellow" },
  ["@type.definition"] = { fg = "$yellow", fmt = "bold" },
  ["@type.builtin"] = { fg = "$red" },
  ["@module"] = { fg = "$yellow" },
  ["@module.builtin"] = { fg = "$red" },
  ["@constant"] = { fg = "$orange" },
  ["@constant.builtin"] = { fg = "$red" },
  ["@number"] = { fg = "$orange" },
  ["@boolean"] = { fg = "$orange" },
  ["@string"] = { fg = "$green" },
  ["@string.escape"] = { fg = "$purple" },
  ["@string.regexp"] = { fg = "$purple" },
  ["@attribute"] = { fg = "$orange" },
  ["@tag"] = { fg = "$red" },
  ["@tag.attribute"] = { fg = "$purple" },
  ["@tag.delimiter"] = { fg = "$cyan" },
}

for level = 1, 6 do
  syntax["@markup.heading." .. level .. ".markdown"] = { fg = "$purple", fmt = "bold" }
  syntax["@markup.heading." .. level] = { fg = "$purple", fmt = "bold" }
end

-- onedark copies treesitter specs into LSP semantic token groups at load time,
-- so they need the same overrides or LSP-attached buffers keep onedark colours
local lsp_to_syntax = {
  ["@lsp.type.keyword"] = "@keyword",
  ["@lsp.type.namespace"] = "@module",
  ["@lsp.type.parameter"] = "@variable.parameter",
  ["@lsp.type.property"] = "@property",
  ["@lsp.type.variable"] = "@variable",
  ["@lsp.type.method"] = "@function.method",
  ["@lsp.type.function"] = "@function",
  ["@lsp.type.builtinType"] = "@type.builtin",
  ["@lsp.typemod.method.defaultLibrary"] = "@function.builtin",
  ["@lsp.typemod.function.defaultLibrary"] = "@function.builtin",
  ["@lsp.typemod.variable.defaultLibrary"] = "@variable.builtin",
  ["@lsp.typemod.variable.injected"] = "@variable",
}

local highlights = vim.deepcopy(syntax)
for lsp_group, syntax_group in pairs(lsp_to_syntax) do
  highlights[lsp_group] = syntax[syntax_group]
end

return {
  "navarasu/onedark.nvim",
  enabled = true,
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require('onedark').setup {
      style = 'darker',
      colors = opencode_colors,
      highlights = highlights,
    }
    require('onedark').load()
  end
}
