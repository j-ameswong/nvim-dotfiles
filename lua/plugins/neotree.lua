return {
  "nvim-neo-tree/neo-tree.nvim",
  -- The 'opts' table contains only your custom configurations
  opts = {
    -- 1. WINDOW & KEYMAPPING CHANGES
    window = {
      mapping_options = {
        nowait = true, -- Default
        noremap = true, -- Default
      },
      mappings = {
        ["<space>"] = {
          "toggle_node",
          nowait = false,
        },
        ["P"] = {
          "toggle_preview",
          config = {
            use_float = true,
            use_snacks_image = true,
            use_image_nvim = true,
          },
        },
        ["Z"] = "expand_all_subnodes",
      },
    },

    -- 2. GLOBAL CUSTOM COMMAND
    commands = {
      open_visual = function(state, selected_nodes)
        local utils = require("neo-tree.utils")
        if not selected_nodes or #selected_nodes == 0 then
          vim.notify("No files selected", vim.log.levels.WARN, { title = "Neo-tree" })
          return
        end
        for _, node in ipairs(selected_nodes) do
          if node.type == "file" then
            local path = node.path or node:get_id()
            local bufnr = node.extra and node.extra.bufnr
            utils.open_file(state, path, "e", bufnr)
          end
        end
        vim.cmd("Neotree close")
      end,
    },

    filesystem = {
      follow_current_file = {
        enabled = false,
        leave_dirs_open = false,
      },
      -- Change: Disable libuv file watcher
      use_libuv_file_watcher = false,
    },

    -- 4. ICON & APPEARANCE CHANGES
    default_component_configs = {
      git_status = {
        symbols = {
          added = "",
          modified = "",
          deleted = "✖", -- Retained as it's a change from the default empty string
        },
      },
    },

    git_status = {
      window = {
        position = "float",
      },
    },

    -- Include these to preserve your file-type specific settings if they are not the LazyVim defaults
    open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
  },
}
