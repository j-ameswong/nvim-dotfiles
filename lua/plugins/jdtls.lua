return {
  "mfussenegger/nvim-jdtls",

  opts = function(opts)
    -- Workspace per project
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

    -- Mason paths
    local home = os.getenv("HOME")
    require("lazyvim.util").ensure_installed("jdtls")
    -- local jdtls_path = home .. "/.local/share/nvim/mason/packages/jdtls"
    -- local config_dir = jdtls_path .. "/config_linux"
    -- local plugins_dir = jdtls_path .. "/plugins"
    -- local equinox_launcher = vim.fn.glob(plugins_dir .. "/org.eclipse.equinox.launcher_*.jar")

    -- Blink LSP capabilities (IMPORTANT)
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    pcall(function()
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
    end)

    local jdtls_config = {
      -- cmd = {
      --   "java",
      --   "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      --   "-Dosgi.bundles.defaultStartLevel=4",
      --   "-Declipse.product=org.eclipse.jdt.ls.core.product",
      --   "-Dlog.level=ALL",
      --   "-Xms1g",
      --   "-Xmx2g",
      --   "-jar",
      --   equinox_launcher,
      --   "-configuration",
      --   config_dir,
      --   "-data",
      --   workspace_dir,
      -- },

      capabilities = capabilities,

      settings = {
        java = {
          configuration = {
            runtimes = {
              {
                name = "JavaSE-25",
                path = "/usr/lib/jvm/java-25-openjdk",
              },
            },
          },
        },
      },
    }
    for k, v in pairs(jdtls_config) do
      opts[k] = v
    end
    return opts
  end,
}
