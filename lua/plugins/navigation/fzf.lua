-- Locked defaults: ../../../plugin-defaults/fzf-lua.md @ 78b85d2a522b1e6a2d154216b3e532a1df1ad6d7
return {
  "ibhagwan/fzf-lua",
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
