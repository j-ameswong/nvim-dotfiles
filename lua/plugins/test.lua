return {
  "quolpr/quicktest.nvim",
  config = function()
    local qt = require("quicktest")

    qt.setup({
      -- Choose your adapter, here all supported adapters are listed
      adapters = {
        require("quicktest.adapters.golang")({}),
        require("quicktest.adapters.vitest")({}),
        require("quicktest.adapters.playwright")({}),
        require("quicktest.adapters.pytest")({}),
        require("quicktest.adapters.elixir"),
        require("quicktest.adapters.criterion"),
        require("quicktest.adapters.dart"),
        require("quicktest.adapters.rspec"),
      },
      -- split or popup mode, when argument not specified
      default_win_mode = "split",
      use_builtin_colorizer = true,
    })
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    {
      "<leader>tl",
      function()
        local qt = require("quicktest")
        -- current_win_mode return currently opened panel, split or popup
        qt.run_line()
        -- You can force open split or popup like this:
        -- qt.run_line('split')
        -- qt.run_line('popup')
      end,
      desc = "[T]est Run [L]line",
    },
    {
      "<leader>tf",
      function()
        local qt = require("quicktest")

        qt.run_file()
      end,
      desc = "[T]est Run [F]ile",
    },
    {
      "<leader>td",
      function()
        local qt = require("quicktest")

        qt.run_dir()
      end,
      desc = "[T]est Run [D]ir",
    },
    {
      "<leader>ta",
      function()
        local qt = require("quicktest")

        qt.run_all()
      end,
      desc = "[T]est Run [A]ll",
    },
    {
      "<leader>tp",
      function()
        local qt = require("quicktest")

        qt.run_previous()
      end,
      desc = "[T]est Run [P]revious",
    },
    {
      "<leader>tt",
      function()
        local qt = require("quicktest")

        qt.toggle_win("split")
      end,
      desc = "[T]est [T]oggle Window",
    },
    {
      "<leader>tc",
      function()
        local qt = require("quicktest")

        qt.cancel_current_run()
      end,
      desc = "[T]est [C]ancel Current Run",
    },
  },
}
