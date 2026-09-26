-- Locked defaults: ../../../plugin-defaults/fidget.nvim.md @ 9e0201673e08e997e7cf52afca5565c70bd117f3
return {
  {
    "j-hui/fidget.nvim",
    opts = {
      -- Options related to LSP progress subsystem
      progress = {
        display = {
          done_icon = "✓", -- Icon shown when all LSP progress tasks are complete
        },
      },
      -- Options related to notification subsystem
      notification = {
        window = {
          winblend = 0, -- Background transparency
        },
      },
    },
  },
}
