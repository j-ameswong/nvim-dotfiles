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
        -- Change: Set nowait=false for <space> to allow space-bar combos
        ["<space>"] = {
          "toggle_node",
          nowait = false,
        },
        -- Change: Enable and configure image preview options
        ["P"] = {
          "toggle_preview",
          config = {
            use_float = true,
            use_snacks_image = true,
            use_image_nvim = true,
          },
        },
        -- Change: Expand only subnodes instead of all nodes
        ["Z"] = "expand_all_subnodes",
      },
    },

    -- 2. GLOBAL CUSTOM COMMAND
    commands = {
      -- Change: Added custom command for opening visually selected files
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

    -- 3. FILESYSTEM CHANGES
    filesystem = {
      -- Change: Disable auto-following the current file
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
          -- Change: Removed symbols for added and modified
          added = "",
          modified = "",
          deleted = "✖", -- Retained as it's a change from the default empty string
        },
      },
    },

    -- 5. GIT STATUS SOURCE WINDOW POSITION
    git_status = {
      window = {
        -- Change: Use a floating window for the git_status source
        position = "float",
      },
    },

    -- Include these to preserve your file-type specific settings if they are not the LazyVim defaults
    open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
  },
}
