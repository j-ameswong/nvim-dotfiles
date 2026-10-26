-- Locked defaults: ../../../plugin-defaults/fzf-lua.md @ 5b88d6f0af7fcb41d4a8bb340bf70d7e3824ee9d
return {
  "ibhagwan/fzf-lua",
  enabled = true,
  cmd = "FzfLua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "nvim-mini/mini.icons" },
  ---@module "fzf-lua"
  ---@type fzf-lua.Config|{}
  ---@diagnostics disable: missing-fields
  opts = {}
  ---@diagnostics enable: missing-fields
}
