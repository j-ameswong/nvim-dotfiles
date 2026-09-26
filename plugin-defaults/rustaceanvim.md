# rustaceanvim defaults and configuration source

Commit: `3ace64feb1ce3cf3c63e6297e1378a82fe548618`

These are the upstream configuration sources at the locked commit. Defaults defined in code are reproduced verbatim; documentation is included for plugins whose settings are not expressed as one Lua table.

## lua/rustaceanvim/config/check.lua

```lua
---@mod rustaceanvim.config.check rustaceanvim configuration check

local types = require('rustaceanvim.types.internal')

local M = {}

---@param name string Argument name
---@param value unknown Argument value
---@param validator vim.validate.Validator
---   - (`string|string[]`): Any value that can be returned from |lua-type()| in addition to
---     `'callable'`: `'boolean'`, `'callable'`, `'function'`, `'nil'`, `'number'`, `'string'`, `'table'`,
---     `'thread'`, `'userdata'`.
---   - (`fun(val:any): boolean, string?`) A function that returns a boolean and an optional
---     string message.
---@param optional? boolean Argument is optional (may be omitted)
---@param message? string message when validation fails
---@see vim.validate
---@return boolean is_valid
---@return string|nil error_message
local function validate(name, value, validator, optional, message)
  local ok, err = pcall(vim.validate, name, value, validator, optional, message)
  return ok or false, 'rustaceanvim: Invalid config' .. (err and ': ' .. err or '')
end

---Validates the config.
---@param cfg rustaceanvim.Config
---@return boolean is_valid
---@return string|nil error_message
function M.validate(cfg)
  local ok, err
  local tools = cfg.tools
  ok, err = validate('rustaceanvim.tools', tools, 'table')
  if not ok then
    return false, err
  end

  local crate_graph = tools.crate_graph
  ok, err = validate('rustaceanvim.tools.crate_graph', crate_graph, 'table')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.crate_graph.backend', crate_graph.backend, 'string', true)
  if not ok then
    return false, err
  end
  ok, err = validate(
    'rustaceanvim.tools.crate_graph.enabled_graphviz_backends',
    crate_graph.enabled_graphviz_backends,
    'table',
    true
  )
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.crate_graph.full', crate_graph.full, 'boolean')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.crate_graph.output', crate_graph.output, 'string', true)
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.crate_graph.pipe', crate_graph.pipe, 'string', true)
  if not ok then
    return false, err
  end

  local code_actions = tools.code_actions
  ok, err = validate('rustaceanvim.tools.code_actions', code_actions, 'table')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.code_actions.group_icon', code_actions.group_icon, 'string')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.code_actions.ui_select_fallback', code_actions.ui_select_fallback, 'boolean')
  if not ok then
    return false, err
  end
  local keys = code_actions.keys
  ok, err = validate('rustaceanvim.tools.code_actions.keys', keys, 'table')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.code_actions.keys.confirm', keys.confirm, { 'table', 'string' })
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.code_actions.keys.quit', keys.quit, { 'table', 'string' })
  if not ok then
    return false, err
  end
  local float_win_config = tools.float_win_config
  ok, err = validate('rustaceanvim.tools.float_win_config', float_win_config, 'table')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.float_win_config.auto_focus', float_win_config.auto_focus, 'boolean')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.float_win_config.open_split', float_win_config.open_split, 'string')
  if not ok then
    return false, err
  end
  local rustc = tools.rustc
  ok, err = validate('rustaceanvim.tools.rustc', rustc, 'table')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.rustc.default_edition', rustc.default_edition, 'string')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.executor', tools.executor, { 'table', 'string' })
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.test_executor', tools.test_executor, { 'table', 'string' })
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.crate_test_executor', tools.crate_test_executor, { 'table', 'string' })
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.cargo_override', tools.cargo_override, 'string', true)
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.enable_nextest', tools.enable_nextest, 'boolean')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.enable_clippy', tools.enable_clippy, 'boolean')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.on_initialized', tools.on_initialized, 'function', true)
  if not ok then
    return false, err
  end
  ok, err =
    validate('rustaceanvim.tools.reload_workspace_from_cargo_toml', tools.reload_workspace_from_cargo_toml, 'boolean')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.open_url', tools.open_url, 'function', true)
  if not ok then
    return false, err
  end
  local server = cfg.server
  ok, err = validate('rustaceanvim.server', server, 'table')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.server.cmd', server.cmd, { 'function', 'table' })
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.server.standalone', server.standalone, 'boolean')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.server.settings', server.settings, { 'function', 'table' }, true)
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.server.root_dir', server.root_dir, { 'function', 'string' }, true)
  if not ok then
    return false, err
  end
  if type(server.settings) == 'table' then
    ok, err = validate('rustaceanvim.server.settings[rust-analyzer]', server.settings['rust-analyzer'], 'table', true)
    if not ok then
      return false, err
    end
  end

  local dap = cfg.dap
  ok, err = validate('rustaceanvim.dap', dap, 'table')
  if not ok then
    return false, err
  end

  local adapter = types.evaluate(dap.adapter)
  if adapter == false then
    ok = true
  elseif adapter.type == 'executable' then
    ---@cast adapter rustaceanvim.dap.executable.Config
    ok, err = validate('rustaceanvim.dap.adapter.command [executable]', adapter.command, 'string')
    if not ok then
      return false, err
    end
    ok, err = validate('rustaceanvim.dap.adapter.name [executable]', adapter.name, 'string', true)
    if not ok then
      return false, err
    end
    ok, err = validate('rustaceanvim.dap.adapter.args [executable]', adapter.args, 'table', true)
    if not ok then
      return false, err
    end
  elseif adapter.type == 'server' then
    ---@cast adapter rustaceanvim.dap.server.Config
    local executable = adapter.executable
    ok, err = validate('rustaceanvim.dap.adapter.executable [server]', executable, 'table')
    if not ok then
      return false, err
    end
    ok, err = validate('rustaceanvim.dap.adapter.executable.command [server]', executable.command, 'string')
    if not ok then
      return false, err
    end
    ok, err = validate('rustaceanvim.dap.adapter.executable.args [server]', executable.args, 'table', true)
    if not ok then
      return false, err
    end
    ok, err = validate('rustaceanvim.dap.adapter.name [server]', adapter.name, 'string', true)
    if not ok then
      return false, err
    end
    ok, err = validate('rustaceanvim.dap.adapter.host [server]', adapter.host, 'string', true)
    if not ok then
      return false, err
    end
    ok, err = validate('rustaceanvim.dap.adapter.port [server]', adapter.port, 'string')
    if not ok then
      return false, err
    end
  else
    ok = false
    err =
      'rustaceanvim.dap.adapter:\nExpected rustaceanvim.dap.executable.Config, rustaceanvim.dap.server.Config or false'
  end
  if not ok then
    return false, err
  end
  return true
end

---@param callback fun(msg: string)
function M.check_for_lspconfig_conflict(callback)
  for _, autocmd in ipairs(vim.api.nvim_get_autocmds { event = 'FileType', pattern = 'rust' }) do
    if
      autocmd.group_name
      and autocmd.group_name == 'lspconfig'
      and autocmd.desc
      and autocmd.desc:match('rust_analyzer')
    then
      callback([[
nvim-lspconfig.rust_analyzer has been setup.
This will likely lead to conflicts with the rustaceanvim LSP client.
See ':h rustaceanvim.mason'
]])
      return
    end
  end
end

return M

```

## lua/rustaceanvim/config/init.lua

```lua
---@mod rustaceanvim.config plugin configuration
---
---@brief [[
---
---rustaceanvim is a filetype plugin, and does not need
---a `setup` function to work.
---
---To configure rustaceanvim, set the variable `vim.g.rustaceanvim`,
---which is a |rustaceanvim.Opts| table, in your neovim configuration.
---
---Example:
---
--->lua
------@type rustaceanvim.Opts
---vim.g.rustaceanvim = {
---   ---@type rustaceanvim.tools.Opts
---   tools = {
---     -- ...
---   },
---   ---@type rustaceanvim.lsp.ClientOpts
---   server = {
---     on_attach = function(client, bufnr)
---       -- Set keybindings, etc. here.
---     end,
---     default_settings = {
---       -- rust-analyzer language server configuration
---       ['rust-analyzer'] = {
---       },
---     },
---     -- ...
---   },
---   ---@type rustaceanvim.dap.Opts
---   dap = {
---     -- ...
---   },
--- }
---<
---
---Notes:
---
--- - `vim.g.rustaceanvim` can also be a function that returns a |rustaceanvim.Opts| table.
--- - You can also configure the rust-analyzer LSP client using a `.vscode/settings.json` file
---   or via |vim.lsp.config()| (using the `'rust-analyzer'` key).
---
---@brief ]]

local config = {}

---@type rustaceanvim.Opts | fun():rustaceanvim.Opts | nil
vim.g.rustaceanvim = vim.g.rustaceanvim

---@class rustaceanvim.Opts
---
---Plugin options.
---@field tools? rustaceanvim.tools.Opts
---
---Language server client options.
---Some fields can also be set using |vim.lsp.config()| for "rust-analyzer" or "*".
---If both the `server` table and a `vim.lsp.config["rust-analyzer"]` are defined,
---rustaceanvim merges |vim.lsp.config()| settings into the `server` table,
---giving them precedence over existing settings.
---Note that |vim.lsp.config()| expects a |vim.lsp.ClientConfig|.
---Although you can also pass in |rustaceanvim.lsp.ClientOpts|, doing so is not
-- officially supported and may not be possible in the future.
---@field server? rustaceanvim.lsp.ClientOpts
---
---Debug adapter options
---@field dap? rustaceanvim.dap.Opts

---@class rustaceanvim.tools.Opts
---
---The executor to use for runnables/debuggables
---@field executor? rustaceanvim.Executor | rustaceanvim.executor_alias
---
---The executor to use for runnables that are tests / testables
---@field test_executor? rustaceanvim.Executor | rustaceanvim.test_executor_alias
---
---The executor to use for runnables that are crate test suites (--all-targets)
---@field crate_test_executor? rustaceanvim.Executor | rustaceanvim.test_executor_alias
---
---Set this to override the 'cargo' command for runnables, debuggables (etc., e.g. to 'cross').
---If set, this takes precedence over 'enable_nextest'.
---@field cargo_override? string
---
---Whether to enable nextest. If enabled, `cargo test` commands will be transformed to `cargo nextest run` commands.
---Defaults to `true` if cargo-nextest is detected. Ignored if `cargo_override` is set.
---@field enable_nextest? boolean
---
---Whether to enable clippy checks on save if a clippy installation is detected.
---Default: `true`
---@field enable_clippy? boolean
---
---Function that is invoked when the LSP server has finished initializing
---@field on_initialized? fun(health:rustaceanvim.RAInitializedStatus, client_id:integer)
---
---Automatically call `RustReloadWorkspace` when writing to a Cargo.toml file
---@field reload_workspace_from_cargo_toml? boolean
---@field code_actions? rustaceanvim.code-action.Opts Options for code actions
---
---Options applied to floating windows.
---See |api-win_config|.
---@field float_win_config? rustaceanvim.FloatWinConfig
---
---Options for showing the crate graph based on graphviz and the dot
---@field create_graph? rustaceanvim.crate-graph.Opts
---
---If set, overrides how to open URLs
---@field open_url? fun(url:string):nil
---
---Options for `rustc`
---@field rustc? rustaceanvim.rustc.Opts

---@class rustaceanvim.Executor
---@field execute_command fun(cmd:string, args:string[], cwd:string|nil, opts?: rustaceanvim.ExecutorOpts)

---@class rustaceanvim.ExecutorOpts
---
---The buffer from which the executor was invoked.
---@field bufnr? integer
---The environment variables to set for the command.
---@field env? table<string, string>

---@class rustaceanvim.FloatWinConfig
---@field auto_focus? boolean
---@field open_split? 'horizontal' | 'vertical'
---@see vim.lsp.util.open_floating_preview.Opts
---@see vim.api.nvim_open_win

---@alias rustaceanvim.executor_alias 'termopen' | 'quickfix' | 'toggleterm' | 'vimux'

---@alias rustaceanvim.test_executor_alias rustaceanvim.executor_alias | 'background' | 'neotest'

---@class rustaceanvim.code-action.Opts
---
---Text appended to a group action
---@field group_icon? string
---
---Whether to fall back to `vim.ui.select` if there are no grouped code actions.
---Default: `false`
---@field ui_select_fallback? boolean
---
---@field keys rustaceanvim.code-action.Keys

---@class rustaceanvim.code-action.Keys
---
---The key or keys with which to confirm a code action
---Default: `"<CR>"`.
---@field confirm? string | string[]
---
---The key or keys with which to close a code action window
---Default: `{ "q", "<Esc>" }`.
---@field quit? string

---@alias rustaceanvim.lsp_server_health_status 'ok' | 'warning' | 'error'

---@class rustaceanvim.RAInitializedStatus
---@field health rustaceanvim.lsp_server_health_status

---@class rustaceanvim.crate-graph.Opts
---
---Backend used for displaying the graph.
---See: https://graphviz.org/docs/outputs/
---Defaults to `"x11"` if unset.
---@field backend? string
---
---Where to store the output. No output if unset.
---Relative path from `cwd`.
---@field output? string
---
---Override the enabled graphviz backends list, used for input validation and autocompletion.
---@field enabled_graphviz_backends? string[]
---
---Override the pipe symbol in the shell command.
---Useful if using a shell that is not supported by this plugin.
---@field pipe? string

---@class rustaceanvim.rustc.Opts
---
---The default edition to use if it cannot be auto-detected.
---See https://rustc-dev-guide.rust-lang.org/guides/editions.html.
---Default '2021'.
---@field default_edition? string

---@class rustaceanvim.lsp.ClientOpts
---
---Whether to automatically attach the LSP client.
---Defaults to `true` if the `rust-analyzer` executable is found.
---@field auto_attach? boolean | fun(bufnr: integer):boolean
---
---Command and arguments for starting rust-analyzer
---Can be a list of arguments, a function that returns a list of arguments,
---or a function that returns an LSP RPC client factory (see |vim.lsp.rpc.connect|).
---@field cmd? string[] | fun():(string[]|fun(dispatchers: vim.lsp.rpc.Dispatchers): vim.lsp.rpc.PublicClient)
---
---The directory to use for the attached LSP.
---Can be a function, which may return nil if no server should attach.
---The second argument contains the default implementation, which can be used for fallback behavior.
---@field root_dir? string | fun(filename: string, default: fun(filename: string):string|nil):string|nil
---
---Options for connecting to lspmux.
---@field lspmux? rustaceanvim.lspmux.Opts
---
---Setting passed to rust-analyzer.
---By default, this is a function that configures rust-analyzer
---based on your environment (e.g. based on whether clippy is installed).
---If you want to keep this behaviour, use the `default_settings` field (see below)
-- to override defaults.
---See https://rust-analyzer.github.io/book/configuration.
---@field settings? table | fun(project_root:string|nil, default_settings: table):table
---
---The `default_settings` passed as the second argument to the `settings` function (see above).
---See https://rust-analyzer.github.io/book/configuration.
---@field default_settings? table
---
---Standalone file support (enabled by default).
---Disabling it may improve rust-analyzer's startup time.
---@field standalone? boolean
---
---The path to the rust-analyzer log file.
---@field logfile? string
---
---Whether to search (upward from the buffer) for rust-analyzer settings in .vscode/settings json.
---If found, loaded settings will override configured options.
---Default: `true`
---@field load_vscode_settings? boolean
---
---Server status warning level to notify at.
---Default: 'error'
---@field status_notify_level? rustaceanvim.server.status_notify_level
---
---@see vim.lsp.ClientConfig

---@class rustaceanvim.lspmux.Opts
---
---Whether to enable lspmux auto-discovery.
---Default: `true` if `server.cmd` is not set, otherwise `false`.
---If enabled, rustaceanvim will try to detect if an lspmux server is running
---and connect to it (Linux and MacOS only).
---If auto-discovery does not work, you can set `server.cmd` to a function that
---returns an LSP RPC client factory (see |vim.lsp.rpc.connect|).
---@field enable? boolean
---
---The host to connect to. Default: '127.0.0.1'
---@field host? string
---
---The port to connect to. Default: 27631
---@field port? integer

---@alias rustaceanvim.server.status_notify_level 'error' | 'warning' | rustaceanvim.disable

---@alias rustaceanvim.disable false

---@class rustaceanvim.dap.Opts
---
---Whether to autoload nvim-dap configurations when rust-analyzer has attached?
---Default: `true`
---@field autoload_configurations? boolean
---
---Defaults to creating the `rt_lldb` adapter, which is a |rustaceanvim.dap.server.Config|
---if `codelldb` is detected, and a |rustaceanvim.dap.executable.Config|` if `lldb` is detected.
---Set to `false` to disable.
---@field adapter? rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config | rustaceanvim.disable | fun():(rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config | rustaceanvim.disable)
---
---Dap client configuration. Defaults to a function that looks for a `launch.json` file
---or returns a |rustaceanvim.dap.executable.Config| that launches the `rt_lldb` adapter.
---Set to `false` to disable.
---@field configuration? rustaceanvim.dap.client.Config | rustaceanvim.disable | fun():(rustaceanvim.dap.client.Config | rustaceanvim.disable)
---
---Accommodate dynamically-linked targets by passing library paths to lldb.
---Default: `true`.
---@field add_dynamic_library_paths? boolean | fun():boolean
---
---Whether to auto-generate a source map for the standard library.
---@field auto_generate_source_map? fun():boolean | boolean
---
---Whether to get Rust types via initCommands (rustlib/etc/lldb_commands, lldb only).
---Default: `true`.
---@field load_rust_types? fun():boolean | boolean

---@alias rustaceanvim.dap.Command string

---@class rustaceanvim.dap.executable.Config
---
---The type of debug adapter.
---@field type rustaceanvim.dap.adapter.types.executable
---@field command string Default: `"lldb-vscode"`.
---@field args? string Default: unset.
---@field name? string Default: `"lldb"`.

---@class rustaceanvim.dap.server.Config
---@field type rustaceanvim.dap.adapter.types.server The type of debug adapter.
---@field host? string The host to connect to.
---@field port string The port to connect to.
---@field executable rustaceanvim.dap.Executable The executable to run
---@field name? string

---@class rustaceanvim.dap.Executable
---@field command string The executable.
---@field args string[] Its arguments.

---@alias rustaceanvim.dap.adapter.types.executable "executable"
---@alias rustaceanvim.dap.adapter.types.server "server"

---@class rustaceanvim.dap.client.Config: dap.Configuration
---@field type string The dap adapter to use
---@field name string
---@field request rustaceanvim.dap.config.requests.launch | rustaceanvim.dap.config.requests.attach | rustaceanvim.dap.config.requests.custom The type of dap session
---@field cwd? string Current working directory
---@field program? string Path to executable for most DAP clients
---@field args? string[] Optional args to DAP client, not valid for all client types
---@field env? rustaceanvim.EnvironmentMap Environmental variables
---@field initCommands? string[] Initial commands to run, `lldb` clients only
---
---Essential config values for `probe-rs` client, see https://probe.rs/docs/tools/debugger/
---@field coreConfigs? table

---@alias rustaceanvim.EnvironmentMap table<string, string[]>

---@alias rustaceanvim.dap.config.requests.launch "launch"
---@alias rustaceanvim.dap.config.requests.attach "attach"
---@alias rustaceanvim.dap.config.requests.custom "custom"

---For the heroes who want to use it.
---@param codelldb_path string Path to the codelldb executable
---@param liblldb_path string Path to the liblldb dynamic library
---@return rustaceanvim.dap.server.Config
function config.get_codelldb_adapter(codelldb_path, liblldb_path)
  return {
    type = 'server',
    port = '${port}',
    host = '127.0.0.1',
    executable = {
      command = codelldb_path,
      args = { '--liblldb', liblldb_path, '--port', '${port}' },
    },
  }
end

return config

```

## lua/rustaceanvim/config/internal.lua

```lua
local types = require('rustaceanvim.types.internal')
local config = require('rustaceanvim.config')
local executors = require('rustaceanvim.executors')
local os = require('rustaceanvim.os')
local server_config = require('rustaceanvim.config.server')

local RustaceanConfig

local rustaceanvim = vim.g.rustaceanvim or {}
local rustaceanvim_opts = type(rustaceanvim) == 'function' and rustaceanvim() or rustaceanvim

---Wrapper around |vim.fn.exepath()| that returns the binary if no path is found.
---@param binary string
---@return string the full path to the executable or `binary` if no path is found.
---@see vim.fn.exepath()
local function exepath_or_binary(binary)
  local exe_path = vim.fn.exepath(binary)
  return #exe_path > 0 and exe_path or binary
end

---@class rustaceanvim.internal.RAInitializedStatus : rustaceanvim.RAInitializedStatus
---@field health rustaceanvim.lsp_server_health_status
---@field quiescent boolean inactive?
---@field message string | nil
---
---@param dap_adapter rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config | rustaceanvim.disable
---@return boolean
local function should_enable_dap_config_value(dap_adapter)
  local adapter = types.evaluate(dap_adapter)
  if adapter == false then
    return false
  end
  return vim.fn.executable('rustc') == 1
end

---@param adapter rustaceanvim.dap.server.Config | rustaceanvim.dap.executable.Config
local function is_codelldb_adapter(adapter)
  return adapter.type == 'server'
end

---@param adapter rustaceanvim.dap.server.Config | rustaceanvim.dap.executable.Config
local function is_lldb_adapter(adapter)
  return adapter.type == 'executable'
end

---@param type string
---@return rustaceanvim.dap.client.Config
local function load_dap_configuration(type)
  -- default
  ---@type rustaceanvim.dap.client.Config
  local dap_config = {
    name = 'Rust debug client',
    type = type,
    request = 'launch',
    stopOnEntry = false,
    sourceLanguages = type == 'codelldb' and { 'rust' },
  }
  if type == 'lldb' then
    ---@diagnostic disable-next-line: inject-field
    dap_config.console = 'integratedTerminal'
  end
  ---@diagnostic disable-next-line: different-requires
  local dap = require('dap')
  -- Load configurations from a `launch.json`.
  -- It is necessary to check for changes in the `dap.configurations` table, as
  -- `load_launchjs` does not return anything, it loads directly into `dap.configurations`.
  local pre_launch = vim.deepcopy(dap.configurations) or {}
  for name, configuration_entries in pairs(dap.configurations) do
    if pre_launch[name] == nil or not vim.deep_equal(pre_launch[name], configuration_entries) then
      -- `configurations` are tables of `configuration` entries
      -- use the first `configuration` that matches
      for _, entry in pairs(configuration_entries) do
        ---@cast entry rustaceanvim.dap.client.Config
        if entry.type == type then
          dap_config = entry
          break
        end
      end
    end
  end
  return dap_config
end

---@return rustaceanvim.Executor
local function get_test_executor()
  if package.loaded['rustaceanvim.neotest'] ~= nil then
    -- neotest has been set up with rustaceanvim as an adapter
    return executors.neotest
  end
  return executors.termopen
end

---@class rustaceanvim.Config
local RustaceanDefaultConfig = {
  ---@class rustaceanvim.tools.Config
  tools = {

    --- how to execute terminal commands
    --- options right now: termopen / quickfix / toggleterm / vimux
    ---@type rustaceanvim.Executor
    executor = executors.termopen,

    ---@type rustaceanvim.Executor
    test_executor = get_test_executor(),

    ---@type rustaceanvim.Executor
    crate_test_executor = executors.termopen,

    ---@type string | nil
    cargo_override = nil,

    ---@type boolean
    enable_nextest = vim.fn.executable('cargo-nextest') == 1,

    ---@type boolean
    enable_clippy = true,

    --- callback to execute once rust-analyzer is done initializing the workspace
    --- The callback receives one parameter indicating the `health` of the server: "ok" | "warning" | "error"
    ---@type fun(health:rustaceanvim.RAInitializedStatus, client_id:integer) | nil
    on_initialized = nil,

    --- automatically call RustReloadWorkspace when writing to a Cargo.toml file.
    ---@type boolean
    reload_workspace_from_cargo_toml = true,

    code_actions = {
      --- text appended to a group action
      ---@type string
      group_icon = ' ▶',

      --- whether to fall back to `vim.ui.select` if there are no grouped code actions
      ---@type boolean
      ui_select_fallback = false,

      ---@class rustaceanvim.internal.code_action.Keys
      keys = {
        ---@type string | string[]
        confirm = { '<CR>' },
        ---@type string | string[]
        quit = { 'q', '<Esc>' },
      },
    },

    --- options same as lsp hover
    ---@see vim.lsp.util.open_floating_preview
    ---@see vim.api.nvim_open_win
    ---@type table Options applied to floating windows.
    float_win_config = {
      --- whether the window gets automatically focused
      --- default: false
      ---@type boolean
      auto_focus = false,

      --- whether splits opened from floating preview are vertical
      --- default: false
      ---@type 'horizontal' | 'vertical'
      open_split = 'horizontal',
    },

    --- settings for showing the crate graph based on graphviz and the dot
    --- command
    ---@class rustaceanvim.crate-graph.Config
    crate_graph = {
      -- backend used for displaying the graph
      -- see: https://graphviz.org/docs/outputs/
      -- default: x11
      ---@type string
      backend = 'x11',
      -- where to store the output, nil for no output stored (relative
      -- path from pwd)
      -- default: nil
      ---@type string | nil
      output = nil,
      -- true for all crates.io and external crates, false only the local
      -- crates
      -- default: true
      ---@type boolean
      full = true,

      -- List of backends found on: https://graphviz.org/docs/outputs/
      -- Is used for input validation and autocompletion
      -- Last updated: 2021-08-26
      ---@type string[]
      enabled_graphviz_backends = {
        'bmp',
        'cgimage',
        'canon',
        'dot',
        'gv',
        'xdot',
        'xdot1.2',
        'xdot1.4',
        'eps',
        'exr',
        'fig',
        'gd',
        'gd2',
        'gif',
        'gtk',
        'ico',
        'cmap',
        'ismap',
        'imap',
        'cmapx',
        'imap_np',
        'cmapx_np',
        'jpg',
        'jpeg',
        'jpe',
        'jp2',
        'json',
        'json0',
        'dot_json',
        'xdot_json',
        'pdf',
        'pic',
        'pct',
        'pict',
        'plain',
        'plain-ext',
        'png',
        'pov',
        'ps',
        'ps2',
        'psd',
        'sgi',
        'svg',
        'svgz',
        'tga',
        'tiff',
        'tif',
        'tk',
        'vml',
        'vmlz',
        'wbmp',
        'webp',
        'xlib',
        'x11',
      },
      ---@type string | nil
      pipe = nil,
    },

    ---@type fun(url:string):nil
    open_url = function(url)
      require('rustaceanvim.os').open_url(url)
    end,
    ---settings for rustc
    ---@class rustaceanvim.rustc.Config
    rustc = {
      ---@type string
      default_edition = '2021',
    },
  },

  --- all the opts to send to the LSP client
  --- these override the defaults set by rust-tools.nvim
  ---@class rustaceanvim.lsp.ClientConfig: vim.lsp.ClientConfig
  server = {
    ---@type lsp.ClientCapabilities
    capabilities = server_config.create_client_capabilities(),
    ---@type boolean | fun(bufnr: integer):boolean Whether to automatically attach the LSP client.
    ---Defaults to `true` if the `rust-analyzer` executable is found.
    auto_attach = function(bufnr)
      if #vim.bo[bufnr].buftype > 0 then
        return false
      end
      local path = vim.api.nvim_buf_get_name(bufnr)
      if not os.is_valid_file_path(path) then
        return false
      end
      local cmd = types.evaluate(RustaceanConfig.server.cmd)
      if type(cmd) == 'function' then
        -- This could be a function that connects via a TCP socket, so we don't want to evaluate it.
        return true
      end
      ---@cast cmd string[]
      local rs_bin = cmd[1]
      return vim.fn.executable(rs_bin) == 1
    end,
    ---@type string[] | fun():(string[]|fun(dispatchers: vim.lsp.rpc.Dispatchers): vim.lsp.rpc.PublicClient)
    cmd = function()
      return { exepath_or_binary('rust-analyzer'), '--log-file', RustaceanConfig.server.logfile }
    end,

    --- Defaults to `nil`, which means rustaceanvim will use the built-in async root directory detection
    ---@type nil | string | fun(filename: string, default: fun(filename: string):string|nil):string|nil
    root_dir = nil,

    lspmux = {
      ---@type boolean
      enable = vim.tbl_get(rustaceanvim_opts, 'server', 'cmd') == nil,
      ---@type string
      host = '127.0.0.1',
      ---@type integer
      port = 27631,
    },

    --- standalone file support
    --- setting it to false may improve startup time
    ---@type boolean
    standalone = true,

    ---@type string The path to the rust-analyzer log file.
    logfile = vim.fn.tempname() .. '-rust-analyzer.log',

    ---@type table | (fun(project_root:string|nil, default_settings: table|nil):table) -- The rust-analyzer settings or a function that creates them.
    settings = function(_, default_settings)
      return server_config.load_rust_analyzer_settings(_, { default_settings = default_settings })
    end,

    --- @type table
    default_settings = {
      --- options to send to rust-analyzer
      --- See: https://rust-analyzer.github.io/book/configuration
      --- @type table
      ['rust-analyzer'] = {},
    },
    ---@type boolean Whether to search (upward from the buffer) for rust-analyzer settings in .vscode/settings json.
    load_vscode_settings = true,
    ---@type rustaceanvim.server.status_notify_level
    status_notify_level = 'error',
  },

  --- debugging stuff
  --- @class rustaceanvim.dap.Config
  dap = {
    --- @type boolean Whether to autoload nvim-dap configurations when rust-analyzer has attached?
    autoload_configurations = true,
    --- @type rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config | rustaceanvim.disable | fun():(rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config | rustaceanvim.disable)
    adapter = function()
      --- @type rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config | rustaceanvim.disable
      local result = false
      if vim.fn.executable('codelldb') == 1 then
        ---@cast result rustaceanvim.dap.server.Config
        result = {
          type = 'server',
          host = '127.0.0.1',
          port = '${port}',
          executable = {
            command = exepath_or_binary('codelldb'),
            args = { '--port', '${port}' },
          },
        }
      else
        local has_mason, mason_registry = pcall(require, 'mason-registry')
        local ok, err = pcall(function()
          if has_mason and mason_registry.is_installed('codelldb') then
            local codelldb_package = mason_registry.get_package('codelldb')
            local mason_codelldb_path
            if require('mason.version').MAJOR_VERSION > 1 then
              mason_codelldb_path =
                vim.fs.joinpath(vim.fn.expand('$MASON'), 'packages', codelldb_package.name, 'extension')
            else
              mason_codelldb_path = vim.fs.joinpath(codelldb_package:get_install_path(), 'extension')
            end
            local codelldb_path = vim.fs.joinpath(mason_codelldb_path, 'adapter', 'codelldb')
            local liblldb_path = vim.fs.joinpath(mason_codelldb_path, 'lldb', 'lib', 'liblldb')
            local shell = require('rustaceanvim.shell')
            if shell.is_windows() then
              codelldb_path = codelldb_path .. '.exe'
              liblldb_path = vim.fs.joinpath(mason_codelldb_path, 'lldb', 'bin', 'liblldb.dll')
            else
              liblldb_path = liblldb_path .. (shell.is_macos() and '.dylib' or '.so')
            end
            result = config.get_codelldb_adapter(codelldb_path, liblldb_path)
          else
            local has_lldb_dap = vim.fn.executable('lldb-dap') == 1
            local has_lldb_vscode = vim.fn.executable('lldb-vscode') == 1
            if not has_lldb_dap and not has_lldb_vscode then
              return result
            end
            local command = has_lldb_dap and 'lldb-dap' or 'lldb-vscode'
            ---@cast result rustaceanvim.dap.executable.Config
            result = {
              type = 'executable',
              command = exepath_or_binary(command),
              name = 'lldb',
            }
          end
        end)
        if not ok then
          vim.schedule(function()
            vim.notify(
              ([[
mason.nvim threw an error while trying to detect codelldb:
%s
]]):format(err),
              vim.log.levels.WARN
            )
          end)
        end
      end
      return result
    end,
    --- Accommodate dynamically-linked targets by passing library paths to lldb.
    ---@type boolean | fun():boolean
    add_dynamic_library_paths = function()
      return should_enable_dap_config_value(RustaceanConfig.dap.adapter)
    end,
    --- Auto-generate a source map for the standard library.
    ---@type boolean | fun():boolean
    auto_generate_source_map = function()
      return should_enable_dap_config_value(RustaceanConfig.dap.adapter)
    end,
    --- Get Rust types via initCommands (rustlib/etc/lldb_commands).
    ---@type boolean | fun():boolean
    load_rust_types = function()
      if not should_enable_dap_config_value(RustaceanConfig.dap.adapter) then
        return false
      end
      local adapter = types.evaluate(RustaceanConfig.dap.adapter)
      ---@cast adapter rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config | rustaceanvim.disable
      return adapter ~= false and is_lldb_adapter(adapter)
    end,
    --- @type rustaceanvim.dap.client.Config | rustaceanvim.disable | fun():(rustaceanvim.dap.client.Config | rustaceanvim.disable)
    configuration = function()
      local ok, _ = pcall(require, 'dap')
      if not ok then
        return false
      end
      local adapter = types.evaluate(RustaceanConfig.dap.adapter)
      ---@cast adapter rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config | rustaceanvim.disable
      if adapter == false then
        return false
      end
      ---@cast adapter rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config
      local type = is_codelldb_adapter(adapter) and 'codelldb' or 'lldb'
      return load_dap_configuration(type)
    end,
  },
  -- debug info
  was_g_rustaceanvim_sourced = vim.g.rustaceanvim ~= nil,
}
for _, executor in pairs { 'executor', 'test_executor', 'crate_test_executor' } do
  if
    rustaceanvim_opts.tools
    and rustaceanvim_opts.tools[executor]
    and type(rustaceanvim_opts.tools[executor]) == 'string'
  then
    rustaceanvim_opts.tools[executor] =
      assert(executors[rustaceanvim_opts.tools[executor]], 'Unknown RustaceanExecutor')
  end
end

---@type rustaceanvim.Config
RustaceanConfig = vim.tbl_deep_extend('force', {}, RustaceanDefaultConfig, rustaceanvim_opts)

-- Override user dap.adapter config in a backward compatible way
if rustaceanvim_opts.dap and rustaceanvim_opts.dap.adapter then
  local user_adapter = rustaceanvim_opts.dap.adapter
  local default_adapter = types.evaluate(RustaceanConfig.dap.adapter)
  if
    type(user_adapter) == 'table'
    and type(default_adapter) == 'table'
    and user_adapter.type == default_adapter.type
  then
    ---@diagnostic disable-next-line: inject-field
    RustaceanConfig.dap.adapter = vim.tbl_deep_extend('force', default_adapter, user_adapter)
  elseif user_adapter ~= nil then
    ---@diagnostic disable-next-line: inject-field
    RustaceanConfig.dap.adapter = user_adapter
  end
end

local check = require('rustaceanvim.config.check')
local ok, err = check.validate(RustaceanConfig)
if not ok then
  vim.notify('rustaceanvim: ' .. err, vim.log.levels.ERROR)
end

return RustaceanConfig

```

## lua/rustaceanvim/config/json.lua

```lua
local M = {}

local warnings = {}
local errors = {}
local is_json_config_loaded = false

---@param warning string
local function add_warning(warning)
  table.insert(warnings, warning)
end

---@param err string
local function add_error(err)
  table.insert(errors, err)
end

---@param field_name string | nil
---@param tbl unknown
---@param keys string[]
---@param value unknown
local function tbl_set(field_name, tbl, keys, value)
  local next = table.remove(keys, 1)
  if type(tbl) ~= 'table' then
    add_warning(([[
Ignored field '%s' of invalid type '%s': %s
Please refer to the rust-analyzer documentation at
https://rust-analyzer.github.io/book/%s
]]):format(field_name, type(value), vim.inspect(value), field_name))
    return
  end
  if #keys > 0 then
    tbl[next] = tbl[next] or {}
    field_name = (field_name and field_name .. '.' or '') .. next
    tbl_set(field_name, tbl[next], keys, value)
  else
    tbl[next] = value
  end
end

---@param tbl table
---@param json_key string e.g. "rust-analyzer.check.overrideCommand"
---@param json_value unknown
local function override_tbl_values(tbl, json_key, json_value)
  local keys = vim.split(json_key, '%.')
  tbl_set(nil, tbl, keys, json_value)
end

---@param json_content string
---@return table
function M.silent_decode(json_content)
  warnings = {}
  errors = {}
  local ok, json_tbl = pcall(vim.json.decode, json_content)
  if not ok or type(json_tbl) ~= 'table' then
    add_error(('Failed to decode json: %s'):format(json_tbl or 'unknown error'))
    return {}
  end
  return json_tbl
end

---@param tbl table
---@param json_tbl { [string]: unknown }
---@param key_predicate? fun(string): boolean
function M.override_with_json_keys(tbl, json_tbl, key_predicate)
  if vim.tbl_isempty(json_tbl) then
    return
  end
  is_json_config_loaded = true
  for json_key, value in pairs(json_tbl) do
    if not key_predicate or key_predicate(json_key) then
      override_tbl_values(tbl, json_key, value)
    end
  end
end

---@param tbl table
---@param json_tbl { [string]: unknown }
function M.override_with_rust_analyzer_json_keys(tbl, json_tbl)
  M.override_with_json_keys(tbl, json_tbl, function(key)
    return vim.startswith(key, 'rust-analyzer')
  end)
end

function M.is_json_config_loaded()
  return is_json_config_loaded
end

function M.get_warnings()
  return warnings
end

function M.get_errors()
  return errors
end

return M

```

## lua/rustaceanvim/config/server.lua

```lua
---@mod rustaceanvim.config.server LSP configuration utility

local server = {}

---@class rustaceanvim.LoadRASettingsOpts
---
---Default settings to merge the loaded settings into.
---@field default_settings table|nil

--- Load rust-analyzer settings from a JSON file,
--- falling back to the default settings if none is found or if it cannot be decoded.
---@param _ string|nil The project root (ignored)
---@param opts rustaceanvim.LoadRASettingsOpts|nil
---@return table server_settings
---@see https://rust-analyzer.github.io/book/configuration
function server.load_rust_analyzer_settings(_, opts)
  local config = require('rustaceanvim.config.internal')

  opts = opts or {}
  local settings = opts.default_settings or config.server.default_settings
  local use_clippy = config.tools.enable_clippy and vim.fn.executable('cargo-clippy') == 1
  ---@diagnostic disable-next-line: undefined-field
  if
    settings['rust-analyzer'].check == nil
    and use_clippy
    and type(settings['rust-analyzer'].checkOnSave) ~= 'table'
  then
    ---@diagnostic disable-next-line: inject-field
    settings['rust-analyzer'].check = {
      command = 'clippy',
      extraArgs = { '--no-deps' },
    }
    if type(settings['rust-analyzer'].checkOnSave) ~= 'boolean' then
      ---@diagnostic disable-next-line: inject-field
      settings['rust-analyzer'].checkOnSave = true
    end
  end
  return settings
end

---@return lsp.ClientCapabilities
function server.create_client_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- send actions with hover request
  capabilities.experimental = {
    hoverActions = true,
    colorDiagnosticOutput = true,
    hoverRange = true,
    serverStatusNotification = true,
    snippetTextEdit = true,
    codeActionGroup = true,
    ssr = true,
    localDocs = true,
  }

  -- enable auto-import
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' },
  }

  -- rust analyzer goodies
  local experimental_commands = {
    'rust-analyzer.runSingle',
    'rust-analyzer.showReferences',
    'rust-analyzer.gotoLocation',
    'editor.action.triggerParameterHints',
  }
  if package.loaded['dap'] ~= nil then
    table.insert(experimental_commands, 'rust-analyzer.debugSingle')
  end

  ---@diagnostic disable-next-line: inject-field
  capabilities.experimental.commands = {
    commands = experimental_commands,
  }

  return capabilities
end

return server

```

## LICENSE

```text
                    GNU GENERAL PUBLIC LICENSE
                       Version 2, June 1991

 Copyright (C) 1989, 1991 Free Software Foundation, Inc.,
 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

                            Preamble

  The licenses for most software are designed to take away your
freedom to share and change it.  By contrast, the GNU General Public
License is intended to guarantee your freedom to share and change free
software--to make sure the software is free for all its users.  This
General Public License applies to most of the Free Software
Foundation's software and to any other program whose authors commit to
using it.  (Some other Free Software Foundation software is covered by
the GNU Lesser General Public License instead.)  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
this service if you wish), that you receive source code or can get it
if you want it, that you can change the software or use pieces of it
in new free programs; and that you know you can do these things.

  To protect your rights, we need to make restrictions that forbid
anyone to deny you these rights or to ask you to surrender the rights.
These restrictions translate to certain responsibilities for you if you
distribute copies of the software, or if you modify it.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must give the recipients all the rights that
you have.  You must make sure that they, too, receive or can get the
source code.  And you must show them these terms so they know their
rights.

  We protect your rights with two steps: (1) copyright the software, and
(2) offer you this license which gives you legal permission to copy,
distribute and/or modify the software.

  Also, for each author's protection and ours, we want to make certain
that everyone understands that there is no warranty for this free
software.  If the software is modified by someone else and passed on, we
want its recipients to know that what they have is not the original, so
that any problems introduced by others will not reflect on the original
authors' reputations.

  Finally, any free program is threatened constantly by software
patents.  We wish to avoid the danger that redistributors of a free
program will individually obtain patent licenses, in effect making the
program proprietary.  To prevent this, we have made it clear that any
patent must be licensed for everyone's free use or not licensed at all.

  The precise terms and conditions for copying, distribution and
modification follow.

                    GNU GENERAL PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. This License applies to any program or other work which contains
a notice placed by the copyright holder saying it may be distributed
under the terms of this General Public License.  The "Program", below,
refers to any such program or work, and a "work based on the Program"
means either the Program or any derivative work under copyright law:
that is to say, a work containing the Program or a portion of it,
either verbatim or with modifications and/or translated into another
language.  (Hereinafter, translation is included without limitation in
the term "modification".)  Each licensee is addressed as "you".

Activities other than copying, distribution and modification are not
covered by this License; they are outside its scope.  The act of
running the Program is not restricted, and the output from the Program
is covered only if its contents constitute a work based on the
Program (independent of having been made by running the Program).
Whether that is true depends on what the Program does.

  1. You may copy and distribute verbatim copies of the Program's
source code as you receive it, in any medium, provided that you
conspicuously and appropriately publish on each copy an appropriate
copyright notice and disclaimer of warranty; keep intact all the
notices that refer to this License and to the absence of any warranty;
and give any other recipients of the Program a copy of this License
along with the Program.

You may charge a fee for the physical act of transferring a copy, and
you may at your option offer warranty protection in exchange for a fee.

  2. You may modify your copy or copies of the Program or any portion
of it, thus forming a work based on the Program, and copy and
distribute such modifications or work under the terms of Section 1
above, provided that you also meet all of these conditions:

    a) You must cause the modified files to carry prominent notices
    stating that you changed the files and the date of any change.

    b) You must cause any work that you distribute or publish, that in
    whole or in part contains or is derived from the Program or any
    part thereof, to be licensed as a whole at no charge to all third
    parties under the terms of this License.

    c) If the modified program normally reads commands interactively
    when run, you must cause it, when started running for such
    interactive use in the most ordinary way, to print or display an
    announcement including an appropriate copyright notice and a
    notice that there is no warranty (or else, saying that you provide
    a warranty) and that users may redistribute the program under
    these conditions, and telling the user how to view a copy of this
    License.  (Exception: if the Program itself is interactive but
    does not normally print such an announcement, your work based on
    the Program is not required to print an announcement.)

These requirements apply to the modified work as a whole.  If
identifiable sections of that work are not derived from the Program,
and can be reasonably considered independent and separate works in
themselves, then this License, and its terms, do not apply to those
sections when you distribute them as separate works.  But when you
distribute the same sections as part of a whole which is a work based
on the Program, the distribution of the whole must be on the terms of
this License, whose permissions for other licensees extend to the
entire whole, and thus to each and every part regardless of who wrote it.

Thus, it is not the intent of this section to claim rights or contest
your rights to work written entirely by you; rather, the intent is to
exercise the right to control the distribution of derivative or
collective works based on the Program.

In addition, mere aggregation of another work not based on the Program
with the Program (or with a work based on the Program) on a volume of
a storage or distribution medium does not bring the other work under
the scope of this License.

  3. You may copy and distribute the Program (or a work based on it,
under Section 2) in object code or executable form under the terms of
Sections 1 and 2 above provided that you also do one of the following:

    a) Accompany it with the complete corresponding machine-readable
    source code, which must be distributed under the terms of Sections
    1 and 2 above on a medium customarily used for software interchange; or,

    b) Accompany it with a written offer, valid for at least three
    years, to give any third party, for a charge no more than your
    cost of physically performing source distribution, a complete
    machine-readable copy of the corresponding source code, to be
    distributed under the terms of Sections 1 and 2 above on a medium
    customarily used for software interchange; or,

    c) Accompany it with the information you received as to the offer
    to distribute corresponding source code.  (This alternative is
    allowed only for noncommercial distribution and only if you
    received the program in object code or executable form with such
    an offer, in accord with Subsection b above.)

The source code for a work means the preferred form of the work for
making modifications to it.  For an executable work, complete source
code means all the source code for all modules it contains, plus any
associated interface definition files, plus the scripts used to
control compilation and installation of the executable.  However, as a
special exception, the source code distributed need not include
anything that is normally distributed (in either source or binary
form) with the major components (compiler, kernel, and so on) of the
operating system on which the executable runs, unless that component
itself accompanies the executable.

If distribution of executable or object code is made by offering
access to copy from a designated place, then offering equivalent
access to copy the source code from the same place counts as
distribution of the source code, even though third parties are not
compelled to copy the source along with the object code.

  4. You may not copy, modify, sublicense, or distribute the Program
except as expressly provided under this License.  Any attempt
otherwise to copy, modify, sublicense or distribute the Program is
void, and will automatically terminate your rights under this License.
However, parties who have received copies, or rights, from you under
this License will not have their licenses terminated so long as such
parties remain in full compliance.

  5. You are not required to accept this License, since you have not
signed it.  However, nothing else grants you permission to modify or
distribute the Program or its derivative works.  These actions are
prohibited by law if you do not accept this License.  Therefore, by
modifying or distributing the Program (or any work based on the
Program), you indicate your acceptance of this License to do so, and
all its terms and conditions for copying, distributing or modifying
the Program or works based on it.

  6. Each time you redistribute the Program (or any work based on the
Program), the recipient automatically receives a license from the
original licensor to copy, distribute or modify the Program subject to
these terms and conditions.  You may not impose any further
restrictions on the recipients' exercise of the rights granted herein.
You are not responsible for enforcing compliance by third parties to
this License.

  7. If, as a consequence of a court judgment or allegation of patent
infringement or for any other reason (not limited to patent issues),
conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot
distribute so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you
may not distribute the Program at all.  For example, if a patent
license would not permit royalty-free redistribution of the Program by
all those who receive copies directly or indirectly through you, then
the only way you could satisfy both it and this License would be to
refrain entirely from distribution of the Program.

If any portion of this section is held invalid or unenforceable under
any particular circumstance, the balance of the section is intended to
apply and the section as a whole is intended to apply in other
circumstances.

It is not the purpose of this section to induce you to infringe any
patents or other property right claims or to contest validity of any
such claims; this section has the sole purpose of protecting the
integrity of the free software distribution system, which is
implemented by public license practices.  Many people have made
generous contributions to the wide range of software distributed
through that system in reliance on consistent application of that
system; it is up to the author/donor to decide if he or she is willing
to distribute software through any other system and a licensee cannot
impose that choice.

This section is intended to make thoroughly clear what is believed to
be a consequence of the rest of this License.

  8. If the distribution and/or use of the Program is restricted in
certain countries either by patents or by copyrighted interfaces, the
original copyright holder who places the Program under this License
may add an explicit geographical distribution limitation excluding
those countries, so that distribution is permitted only in or among
countries not thus excluded.  In such case, this License incorporates
the limitation as if written in the body of this License.

  9. The Free Software Foundation may publish revised and/or new versions
of the General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

Each version is given a distinguishing version number.  If the Program
specifies a version number of this License which applies to it and "any
later version", you have the option of following the terms and conditions
either of that version or of any later version published by the Free
Software Foundation.  If the Program does not specify a version number of
this License, you may choose any version ever published by the Free Software
Foundation.

  10. If you wish to incorporate parts of the Program into other free
programs whose distribution conditions are different, write to the author
to ask for permission.  For software which is copyrighted by the Free
Software Foundation, write to the Free Software Foundation; we sometimes
make exceptions for this.  Our decision will be guided by the two goals
of preserving the free status of all derivatives of our free software and
of promoting the sharing and reuse of software generally.

                            NO WARRANTY

  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
REPAIR OR CORRECTION.

  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.

                     END OF TERMS AND CONDITIONS

            How to Apply These Terms to Your New Programs

  If you develop a new program, and you want it to be of the greatest
possible use to the public, the best way to achieve this is to make it
free software which everyone can redistribute and change under these terms.

  To do so, attach the following notices to the program.  It is safest
to attach them to the start of each source file to most effectively
convey the exclusion of warranty; and each file should have at least
the "copyright" line and a pointer to where the full notice is found.

    <one line to give the program's name and a brief idea of what it does.>
    Copyright (C) <year>  <name of author>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

Also add information on how to contact you by electronic and paper mail.

If the program is interactive, make it output a short notice like this
when it starts in an interactive mode:

    Gnomovision version 69, Copyright (C) year name of author
    Gnomovision comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type `show c' for details.

The hypothetical commands `show w' and `show c' should show the appropriate
parts of the General Public License.  Of course, the commands you use may
be called something other than `show w' and `show c'; they could even be
mouse-clicks or menu items--whatever suits your program.

You should also get your employer (if you work as a programmer) or your
school, if any, to sign a "copyright disclaimer" for the program, if
necessary.  Here is a sample; alter the names:

  Yoyodyne, Inc., hereby disclaims all copyright interest in the program
  `Gnomovision' (which makes passes at compilers) written by James Hacker.

  <signature of Ty Coon>, 1 April 1989
  Ty Coon, President of Vice

This General Public License does not permit incorporating your program into
proprietary programs.  If your program is a subroutine library, you may
consider it more useful to permit linking proprietary applications with the
library.  If this is what you want to do, use the GNU Lesser General
Public License instead of this License.

```

## rust-tools.nvim-LICENSE

```text
MIT License

Copyright (c) 2022 Simrat

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```
