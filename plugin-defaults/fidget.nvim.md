# fidget.nvim defaults and configuration source

Commit: `9e0201673e08e997e7cf52afca5565c70bd117f3`

These are the upstream configuration sources at the locked commit. Defaults defined in code are reproduced verbatim; documentation is included for plugins whose settings are not expressed as one Lua table.

## lua/fidget.lua

```lua
---@diagnostic disable: unused-local

---@brief [[
---*fidget-api.txt*     For Neovim version 0.8+            Last change: see Git log
---@brief ]]
---
---@toc fidget.api.toc
---
---@brief [[
---                                                                    *fidget.api*
--- This file contains generated documentation for Fidget's Lua API, though of
--- course you will also find plenty more detail documented in the source code.
---
--- For help setting up this plugin, see |fidget.txt| and |fidget-option.txt|.
---@brief ]]

---Fidget's top-level module.
local fidget        = {}
fidget.progress     = require("fidget.progress")
fidget.notification = require("fidget.notification")
fidget.spinner      = require("fidget.spinner")
fidget.logger       = require("fidget.logger")
local commands      = require("fidget.commands")

--- Set up Fidget plugin.
---
---@param opts table Plugin options. See |fidget-options| or |fidget-option.txt|.
function fidget.setup(opts) end

---@options [[
---@protected
--- Options for |fidget.setup|
fidget.options = {
  progress = fidget.progress,
  notification = fidget.notification,
  logger = fidget.logger,
}
---@options ]]

require("fidget.options").declare(fidget, "", fidget.options, function()
  commands.setup()
  if fidget.options.notification.override_vim_notify then
    fidget.logger.info("overriding vim.notify() with fidget.notify()")
    vim.notify = fidget.notify
  end
  fidget.logger.info("fidget.nvim setup() complete.")
end)

--- Alias for |fidget.notification.notify|.
---@param msg   string|nil  Content of the notification to show to the user.
---@param level Level|nil   How to format the notification.
---@param opts  Options|nil Optional parameters (see |fidget.notification.Options|).
function fidget.notify(msg, level, opts)
  fidget.notification.notify(msg, level, opts)
end

fidget.notify = fidget.notification.notify

return fidget

```

## lua/fidget/options.lua

```lua
--- Declarative options for this plugin (not specific to Fidget).
local M = {}
local health = require("fidget.health")

---@class fidget.DeprecatedOption<T> : { default_value: T, deprecated_option: string|true }

---@generic T
---@param default_value T
---@param advice string|nil
---@return fidget.DeprecatedOption<T>
function M.deprecated(default_value, advice)
  return {
    default_value = default_value,
    deprecated_option = advice or true,
  }
end

--- Declare a table as a fidget module, so we can tell using is_fidget_module().
local function set_fidget_module(m)
  local mt = getmetatable(m)
  if not mt then
    mt = {}
    setmetatable(m, mt)
  end
  mt.fidget_module = true
end

--- Whether this is fidget module, i.e., set_fidget_module() was called on it.
local function is_fidget_module(m)
  if type(m) ~= "table" then
    return false
  end
  local mt = getmetatable(m)
  return mt and mt.fidget_module == true
end

--- Declare a table of available options for a module M. For internal use.
---
--- Those options can be accessed via M.options.
---
--- Also creates M.setup(opts) to merge the given opts with current options.
---
--- Supports "submodules", i.e., redirects certain keys to the options of
--- another module, e.g.:
---
---     options = require("fidget.options")
---
---     local SM = {}
---     local function post_setup()
---       SM.post_bar = SM.options.bar * 2
---     end
---
---     SM.options = {
---       foo = true,
---       bar = 0,
---     }
---     options.declare(SM, SM.options, post_setup)
---
---     ...
---
---     local M = {}
---     M.options = {
---       baz = "baz",
---       sub_module = SM,
---     }
---     options.declare(M, M.options)
---
---     ...
---
---     M.setup {
---       baz = "bazn't",
---       sub_module = {
---         bar = 42
---       },
---     }
---
---     assert(M.options.baz == "bazn't")
---     assert(M.options.sub_module.foo == true)
---     assert(SM.options.bar == 42)
---     assert(SM.post_bar == 42 * 2)
---
--- Designed this way to keep the configuration structure sane and close to the
--- implementation structure (which we assume to be sane xD).
---
---@param mod           table     the module to which options are being attached
---@param name          string    name of the module
---@param default_opts  table     the default set of options
---@param post_setup    function? called after setup() is called
function M.declare(mod, name, default_opts, post_setup)
  set_fidget_module(mod)

  local prefix = name == "" and "" or (name .. ".")

  local options, sub_setup = {}, {}
  for k, v in pairs(default_opts) do
    if is_fidget_module(v) then
      sub_setup[k] = v.setup
      options[k] = v.options
    else
      options[k] = v
    end
  end

  mod.options = options

  ---@param opts table? table of options passed to setup function
  mod.setup = function(opts)
    opts = opts or {}
    for key, setup in pairs(sub_setup) do
      setup(opts[key])
    end
    for key, val in pairs(opts) do
      if not sub_setup[key] then
        if mod.options[key] == nil then
          health.log_unknown_option(prefix .. tostring(key))
        else
          if type(mod.options[key]) == "table" and mod.options[key].deprecated_option then
            health.log_deprecated_option(prefix .. tostring(key), mod.options[key].deprecated_option)
          end
          mod.options[key] = val
        end
      end
    end
    if post_setup then
      post_setup()
    end
  end
end

return M

```

## lua/fidget/progress.lua

```lua
---@mod fidget.progress LSP progress subsystem
local progress      = {}
progress.display    = require("fidget.progress.display")
progress.lsp        = require("fidget.progress.lsp")
progress.handle     = require("fidget.progress.handle")
local poll          = require("fidget.poll")
local notification  = require("fidget.notification")
local logger        = require("fidget.logger")

--- Table of progress-related autocmds, used to ensure setup() re-entrancy.
local autocmds      = {}

---@options progress [[
---@protected
--- Progress options
progress.options    = {
  --- How and when to poll for progress messages
  ---
  --- Set to `0` to immediately poll on each |LspProgress| event.
  ---
  --- Set to a positive number to poll for progress messages at the specified
  --- frequency (Hz, i.e., polls per second). Combining a slow `poll_rate`
  --- (e.g., `0.5`) with the `ignore_done_already` setting can be used to filter
  --- out short-lived progress tasks, de-cluttering notifications.
  ---
  --- Note that if too many LSP progress messages are sent between polls,
  --- Neovim's progress ring buffer will overflow and messages will be
  --- overwritten (dropped), possibly causing stale progress notifications.
  --- Workarounds include using the |fidget.option.progress.lsp.progress_ringbuf_size|
  --- option, or manually calling |fidget.notification.reset| (see #167).
  ---
  --- Set to `false` to disable polling altogether; you can still manually poll
  --- progress messages by calling |fidget.progress.poll|.
  ---
  ---@type number|false
  poll_rate = 0,

  --- Suppress new messages while in insert mode
  ---
  --- Note that progress messages for new tasks will be dropped, but existing
  --- tasks will be processed to completion.
  ---
  ---@type boolean
  suppress_on_insert = false,

  --- Ignore new tasks that are already complete
  ---
  --- This is useful if you want to avoid excessively bouncy behavior, and only
  --- seeing notifications for long-running tasks. Works best when combined with
  --- a low `poll_rate`.
  ---
  ---@type boolean
  ignore_done_already = false,

  --- Ignore new tasks that don't contain a message
  ---
  --- Some servers may send empty messages for tasks that don't actually exist.
  --- And if those tasks are never completed, they will become stale in Fidget.
  --- This option tells Fidget to ignore such messages unless the LSP server has
  --- anything meaningful to say. (See #171)
  ---
  --- Note that progress messages for new empty tasks will be dropped, but
  --- existing tasks will be processed to completion.
  ---
  ---@type boolean
  ignore_empty_message = false,

  --- How to get a progress message's notification group key
  ---
  --- Set this to return a constant to group all LSP progress messages together,
  --- e.g.,
  --->lua
  ---     notification_group = function(msg)
  ---       -- N.B. you may also want to configure this group key ("lsp_progress")
  ---       -- using progress.display.overrides or notification.configs
  ---       return "lsp_progress"
  ---     end
  ---<
  ---
  ---@type fun(msg: ProgressMessage): Key
  notification_group = function(msg)
    return msg.lsp_client.name
  end,

  --- Clear notification group when LSP server detaches
  ---
  --- This option should be set to a function that, given a client ID number,
  --- returns the notification group to clear. No group will be cleared if
  --- the function returns `nil`.
  ---
  --- The default setting looks up and returns the LSP client name, which is
  --- also used by |fidget.option.progress.notification_group|.
  ---
  --- Set this option to `false` to disable this feature entirely
  --- (no |LspDetach| callback will be installed).
  ---
  ---@type false|fun(client_id: number): Key
  clear_on_detach = function(client_id)
    local client = vim.lsp.get_client_by_id(client_id)
    return client and client.name or nil
  end,

  --- List of filters to ignore LSP progress messages
  ---
  --- Each filter is either a string or a function.
  ---
  --- If it is a string, then it is treated as the name of a LSP server;
  --- messages from that server are ignored.
  ---
  --- If it is a function, then the progress message object is passed to the
  --- function. If the function returns a truthy value, then that message is
  --- ignored.
  ---
  --- Example:
  --->lua
  ---     ignore = {
  ---       "rust_analyzer",  -- Ignore all messages from rust-analyzer
  ---       function(msg)     -- Ignore messages containing "ing"
  ---         return string.find(msg.title, "ing") ~= nil
  ---       end,
  ---     }
  ---<
  ---
  ---@type (string|fun(msg: ProgressMessage): any)[]
  ignore = {},

  display = progress.display,
  lsp = progress.lsp,
}
---@options ]]

progress.client_ids = {}

require("fidget.options").declare(progress, "progress", progress.options, function()
  -- Ensure setup() reentrancy
  for _, autocmd in pairs(autocmds) do
    vim.api.nvim_del_autocmd(autocmd)
  end
  autocmds = {}

  if progress.options.poll_rate ~= false then
    autocmds["LspProgress"] = progress.lsp.on_progress_message(function()
      if progress.options.poll_rate > 0 then
        progress.poller:start_polling(progress.options.poll_rate)
      else
        progress.poller:poll_once()
      end
    end)
  end

  if progress.options.clear_on_detach then
    autocmds["LspDetach"] = progress.lsp.on_detach(progress.on_detach)
  end
end)

--- Whether progress message updates are suppressed.
local progress_suppressed = false

--- Cache of generated LSP notification group configs.
---
---@type { [Key]: Config }
local loaded_configs = {}

--- Lazily load the notification configuration for some progress message.
---
---@protected
---@param msg ProgressMessage
function progress.load_config(msg)
  local group = progress.options.notification_group(msg)
  if loaded_configs[group] then
    return
  end

  local config = progress.display.make_config(group)

  notification.set_config(group, config, false)
end

--- Format a progress message for vim.notify().
---
---@protected
---@param msg ProgressMessage
---@return string|nil message
---@return number     level
---@return Options    opts
function progress.format_progress(msg)
  local group = progress.options.notification_group(msg)
  local message = progress.options.display.format_message(msg)
  local annote = progress.options.display.format_annote(msg)

  local update_only = false
  if progress.options.ignore_done_already and msg.done then
    update_only = true
  elseif progress.options.ignore_empty_message and msg.message == nil then
    update_only = true
  elseif progress.options.suppress_on_insert and string.find(vim.fn.mode(), "i") then
    update_only = true
  end

  return message, vim.log.levels.INFO, {
    key = msg.token,
    group = group,
    annote = annote,
    update_only = update_only,
    ttl = msg.done and 0 or progress.display.options.progress_ttl, -- Use config default when done
    data = msg.done,                                               -- use data to convey whether this task is done
  }
end

--- Poll for progress messages to feed to the fidget notifications subsystem.
---@private
progress.poller = poll.Poller {
  name = "progress",
  poll = function()
    if progress_suppressed then
      return false
    end

    local messages = progress.lsp.poll_for_messages(progress.client_ids)
    if #messages == 0 then
      logger.info("No LSP messages (that can be displayed)")
      return false
    end

    for _, msg in ipairs(messages) do
      -- Determine if we should ignore this message
      local ignore = false
      for _, filter in ipairs(progress.options.ignore) do
        if type(filter) == "string" then
          if msg.lsp_client.name == filter then
            ignore = true
            logger.info("Ignoring LSP progress message by name from", filter, ":", msg)
            break
          end
        elseif type(filter) == "function" then
          if filter(msg) then
            ignore = true
            logger.info("Filtering out LSP progress message", ":", msg)
            break
          end
        else
          logger.error("Unsupported filter type:", type(filter))
        end
      end
      if not ignore then
        logger.info("Notifying LSP progress message from", msg.lsp_client.name, ":", msg.title, " | ", msg.message)
        progress.load_config(msg)
        notification.notify(progress.format_progress(msg))
      end
    end
    return true
  end
}

--- Poll for progress messages once.
---
--- Potentially useful if you're planning on "driving" Fidget yourself.
function progress.poll()
  progress.poller:poll_once()
end

--- Suppress consumption of progress messages.
---
--- Pass `false` as argument to turn off suppression.
---
--- If no argument is given, suppression state is toggled.
---@param suppress boolean|nil Whether to suppress or toggle suppression
function progress.suppress(suppress)
  if suppress == nil then
    progress_suppressed = not progress_suppressed
  else
    progress_suppressed = suppress
  end
end

--- Called upon `LspDetach` event.
---
--- Clears notification group given by `options.clear_on_detach`.
---
---@protected
---@param client_id number
function progress.on_detach(client_id)
  local group_key = progress.options.clear_on_detach(client_id)
  if group_key == nil then
    return
  end
  notification.clear(group_key)
end

return progress

```

## lua/fidget/progress/display.lua

```lua
--- Options and helpers for transforming
local M       = {}
local spinner = require("fidget.spinner")

--- Default format_message implementation.
---
---@param msg ProgressMessage
---@return string progress_notification_message
function M.default_format_message(msg)
  local message = msg.message
  if not message then
    message = msg.done and "Completed" or "In progress..."
  end
  if type(msg.percentage) == "number" then
    message = string.format("%s (%.0f%%)", message, msg.percentage)
  elseif type(msg.percentage) == "string" then
    message = string.format("%s (%s)", message, msg.percentage)
  elseif msg.percentage ~= nil then
    -- We got some percentage but don't know how to format it (uncommon).
    -- Render something anyway so the user knows there's something there.
    message = string.format("%s (???)", message)
  end
  return message
end

---@options progress.display [[
---@protected
--- Progress display options
M.options = {
  --- How many LSP messages to show at once
  ---
  --- If `false`, no limit.
  ---
  --- This is used to configure each LSP notification group, so by default,
  --- this is a per-server limit.
  ---
  ---@type number|false
  render_limit = 16,

  --- How long a message should persist after completion
  ---
  --- Set to `0` to use notification group config default, and `math.huge` to
  --- show notification indefinitely (until overwritten).
  ---
  --- Measured in seconds.
  ---
  ---@type number
  done_ttl = 3,

  --- Icon shown when all LSP progress tasks are complete
  ---
  --- When a string literal is given (e.g., `"✔"`), it is used as a static icon;
  --- when a table (e.g., `{"dots"}` or `{ pattern = "clock", period = 2 }`) is
  --- given, it is used to generate an animation function; when a function is
  --- specified (e.g., `function(now) return now % 2 < 1 and "+" or "-" end`),
  --- it is used as the animation function.
  ---
  --- See also: |fidget.spinner.Manga| and |fidget.spinner.Anime|.
  ---
  ---@type string|Manga|Anime
  done_icon = "✔",

  --- Highlight group for completed LSP tasks
  ---
  ---@type string
  done_style = "Constant",

  --- How long a message should persist when in progress
  ---
  --- Set to `0` to use notification group config default, and `math.huge` to
  --- show notification indefinitely (until overwritten).
  ---
  --- Measured in seconds.
  ---
  ---@type number
  progress_ttl = math.huge,

  --- Icon shown when LSP progress tasks are in progress
  ---
  --- When a string literal is given (e.g., `"✔"`), it is used as a static icon;
  --- when a table (e.g., `{"dots"}` or `{ pattern = "clock", period = 2 }`) is
  --- given, it is used to generate an animation function; when a function is
  --- specified (e.g., `function(now) return now % 2 < 1 and "+" or "-" end`),
  --- it is used as the animation function.
  ---
  ---@type string|Manga|Anime
  progress_icon = { "dots" },

  --- Highlight group for in-progress LSP tasks
  ---
  ---@type string
  progress_style = "WarningMsg",

  --- Highlight group for group name (LSP server name)
  ---
  ---@type string
  group_style = "Title",

  --- Highlight group for group icons
  ---
  ---@type string
  icon_style = "Question",

  --- Ordering priority for LSP notification group
  ---
  ---@type number|false
  priority = 30,

  --- Whether progress notifications should be omitted from history
  ---
  ---@type boolean
  skip_history = true,

  --- How to format a progress message
  ---
  --- Example: ~
  --->lua
  ---     format_message = function(msg)
  ---       if string.find(msg.title, "Indexing") then
  ---         return nil -- Ignore "Indexing..." progress messages
  ---       end
  ---       if msg.message then
  ---         return msg.message
  ---       else
  ---         return msg.done and "Completed" or "In progress..."
  ---       end
  ---     end
  ---<
  ---
  --- Note that the default value is something like:
  --->lua
  ---     function fidget.display.default_format_message(msg)
  ---       local message = msg.message
  ---       if not message then
  ---         message = msg.done and "Completed" or "In progress..."
  ---       end
  ---       if msg.percentage ~= nil then
  ---         message = string.format("%s (%.0f%%)", message, msg.percentage)
  ---       end
  ---       return message
  ---     end
  ---<
  --- (See plugin source code for ground truth in case docs are out of date.)
  ---
  ---@type fun(msg: ProgressMessage): string
  format_message = M.default_format_message,

  --- How to format a progress annotation
  ---
  ---@type fun(msg: ProgressMessage): string
  format_annote = function(msg)
    return msg.title
  end,

  --- How to format a progress notification group's name
  ---
  --- Example:
  ---
  --->lua
  --- format_group_name = function(group)
  ---   return "lsp:" .. tostring(group)
  --- end
  ---<
  ---
  ---@type fun(group: Key): Display
  format_group_name = tostring,

  --- Override options from the default notification config
  ---
  --- Keys of the table are each notification group's `key`.
  ---
  --- Example:
  --->lua
  ---     overrides = {
  ---       hls = {
  ---         name = "Haskell Language Server",
  ---         priority = 60,
  ---         icon = fidget.progress.display.for_icon(fidget.spinner.animate("triangle", 3), "💯"),
  ---         skip_history = false,
  ---       },
  ---       rust_analyzer = {
  ---         name = "Rust Analyzer",
  ---         icon = fidget.progress.display.for_icon(fidget.spinner.animate("arrow", 2.5), "🦀"),
  ---         update_hook = function(item)
  ---           require("fidget.notification").set_content_key(item)
  ---           if item.hidden == nil and string.match(item.annote, "clippy") then
  ---             -- Hide clippy-related notifications
  ---             item.hidden = true
  ---           end
  ---         end,
  ---       },
  ---     }
  ---<
  ---
  ---@type { [Key]: Config }
  overrides = {
    rust_analyzer = { name = "rust-analyzer", },
  },
}
---@options ]]
require("fidget.options").declare(M, "progress.display", M.options)

--- Construct the icon display function, based on two animation functions.
---
---@param progress  string|Anime progress icon/animation function
---@param done      string|Anime completion icon/animation function
---@return Display icon_display
function M.for_icon(progress, done)
  return function(now, items)
    for _, item in ipairs(items) do
      if not item.data then
        -- Still in progress
        return type(progress) == "string" and progress or progress(now)
      end
    end
    return type(done) == "string" and done or done(now)
  end
end

--- Create the config for a language server indexed by the given group key.
---@param group Key
---@return Config
function M.make_config(group)
  local progress = M.options.progress_icon
  if type(progress) == "table" then
    progress = spinner.animate(progress[1] or progress.pattern, progress.period)
  end

  local done = M.options.done_icon
  if type(done) == "table" then
    done = spinner.animate(done[1] or done.pattern, done.period)
  end

  local config = {
    name = M.options.format_group_name(group),
    icon = M.for_icon(progress, done),
    ttl = M.options.done_ttl,
    render_limit = M.options.render_limit or nil,
    group_style = M.options.group_style,
    icon_style = M.options.icon_style,
    annote_style = M.options.progress_style,
    warn_style = M.options.progress_style,
    info_style = M.options.done_style,
    priority = M.options.priority or nil,
    skip_history = M.options.skip_history,
  }

  if M.options.overrides[group] then
    config = vim.tbl_extend("force", config, M.options.overrides[group])
  end

  return config
end

return M

```

## lua/fidget/progress/lsp.lua

```lua
---@mod fidget.progress.lsp Neovim LSP shim layer
local M                    = {}
local logger               = require("fidget.logger")

---@class ProgressMessage
---@field token       Key         Unique identifier used to accumulate updates
---@field title       string|nil  Name of the task in progress
---@field message     string|nil  Message describing the progress
---@field percentage  number|nil  How much of the progress is complete (out of 100)
---@field done        boolean     Whether this progress completed; ignore `percentage` if `done` is `true`
---@field cancellable boolean     Whether this task can be canceled (though doing so is unsupported with Fidget)
---@field lsp_client  table       LSP client table this message came from

--- Autocmd ID for the LSPAttach event.
---@type number?
M.lsp_attach_autocmd       = nil

--- Built-in `$/progress` handler.
---@type function
local lsp_progress_handler = vim.lsp.handlers["$/progress"]

--- Set of attached LSP clients (even those that are inactive)
---@type table<number, true>
local lsp_client_ids       = {}

---@options progress.lsp [[
---@protected
--- Nvim LSP client options
M.options                  = {
  --- Configure the nvim's LSP progress ring buffer size
  ---
  --- Useful for avoiding progress message overflow when the LSP server blasts
  --- more messages than the ring buffer can handle (see #167).
  ---
  --- Leaves the progress ringbuf size at its default if this setting is 0 or
  --- less. Doesn't do anything for Neovim pre-v0.10.0.
  ---
  ---@type number
  progress_ringbuf_size = 0,

  --- Log `$/progress` handler invocations (for debugging)
  ---
  --- Works by wrapping `vim.lsp.handlers["$/progress"]` with Fidget's logger.
  --- Invocations are logged at the `vim.log.levels.INFO` level.
  ---
  --- This option exists primarily for debugging; setting this to `true` is
  --- not recommended.
  ---
  --- Since it works by overriding Neovim's existing `$/progress` handler, you
  --- should not use this function if you'd like Neovim to use your overridden
  --- `$/progress` handler! It will conflict with the handler that Fidget tries
  --- to install for logging purposes.
  log_handler = false,
}
---@options ]]

require("fidget.options").declare(M, "progress.lsp", M.options, function()
  if M.lsp_attach_autocmd ~= nil then
    vim.api.nvim_del_autocmd(M.lsp_attach_autocmd)
    M.lsp_attach_autocmd = nil
  end

  if vim.ringbuf and M.options.progress_ringbuf_size > 0 then
    logger.info("Setting LSP progress ringbuf size to", M.options.progress_ringbuf_size)
    M.lsp_attach_autocmd = vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        client.progress = vim.ringbuf(M.options.progress_ringbuf_size)
        client.progress.pending = {}
      end
    })
  end

  if M.options.log_handler then
    vim.lsp.handlers["$/progress"] = function(x, msg, ctx)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      local tag = string.format("nvim $/progress handler for client %d (%s)", ctx.client_id, client.name)
      logger.info(tag, "invoked:", msg)

      local result = lsp_progress_handler(x, msg, ctx)

      if result ~= nil then
        logger.info(tag, "returned:", result)
      end
    end
  end
end)

--- Consumes LSP progress messages from each client.progress ring buffer.
---
--- Based on vim.lsp.status(), except this implementation does not format the
--- reports into strings.
---
---@return ProgressMessage[] progress_messages
---@see fidget.progress.lsp.ProgressMessage
function M.poll_for_messages()
  local clients = {}

  for client_id in pairs(lsp_client_ids) do
    table.insert(clients, vim.lsp.get_client_by_id(client_id))
  end

  if #clients == 0 then
    return {}
  end

  local messages = {}
  for _, client in ipairs(clients) do
    local client_name = string.format("%s (%s)", client.id, client.name)
    local count = 0
    logger.info("Polling messages from", client_name)
    for progress in client.progress do
      count = count + 1
      local value = progress.value
      if type(value) == 'table' and value.kind then
        local message = {
          token = progress.token,
          title = value.title ~= vim.NIL and value.title or nil,
          message = value.message ~= vim.NIL and value.message or nil,
          percentage = value.done and nil or (value.percentage ~= vim.NIL and value.percentage or nil),
          done = value.kind == "end",
          cancellable = value.cancellable or false,
          lsp_client = client,
        }
        logger.info("Got message from", client_name, ":", value)
        table.insert(messages, message)
      elseif progress.value ~= nil then
        -- Doesn't look like work done progress and can be in any format
        -- Ignore it as there is no sensible way to display it, but we log it
        logger.warn("Dropped message from client", client_name, "of type", type(value))
        logger.info("Dropped message contents:", vim.inspect(value))
      else -- progress.value == nil; nothing to display, nothing interesting to log
        -- Log at INFO level, not at WARN, because apparently some servers do
        -- send these kinds of messages spuriously.
        logger.info("Dropped nil message from client", client_name)
      end
    end
    logger.info("Processed", count, "messages from", client_name)
  end
  return messages
end

--- Register handler for LSP progress updates.
---
---@protected
---@param fn function
---@return number autocommand_id
function M.on_progress_message(fn)
  return vim.api.nvim_create_autocmd("LspProgress", {
    callback = function(event)
      -- Remember client ID (even if it is inactive)
      local client_id = event.data.client_id
      lsp_client_ids[client_id] = true
      fn(event)
    end,
    desc = "Fidget LSP progress handler",
  })
end

--- Register handler for LSP client detach event.
---
---@protected
---@param fn function(client_id: number)
---@return number autocommand_id
function M.on_detach(fn)
  return vim.api.nvim_create_autocmd("LspDetach", {
    callback = function(args)
      -- Forget client ID
      local client_id = args.data.client_id
      lsp_client_ids[client_id] = nil
      fn(client_id)
    end,
    desc = "Fidget LSP detach handler",
  })
end

if not vim.lsp.status then
  -- We're probably not on v0.10.0 yet (i.e., #23958 has yet to land).
  -- Overide with compatibility layer that supports v0.8.0+.

  --- An ephemeron table to track which progress messages we've already seen.
  ---
  --- With weak keys, once a message is removed from the progress table, the Lua
  --- garbage collector will also get rid of it from here.
  local seen_messages = setmetatable({}, { __mode = 'k' })

  --- Based on [vim.lsp.util.get_progress_messages()][get_progress_messages] as it
  --- was implemented in Neovim 0.8.0--0.9.4.
  ---
  --- Adapted with the following changes:
  --- - report.title is simply nil if there is no title
  --- - no need to set report.progress = true
  --- - tokens, client names, and client_id are included in each returned message
  --- - only report new messages that haven't
  ---
  --- Note that to remain compatible with get_progress_messages(), this
  --- implementation does not consume progress messages, i.e., non-done messages
  --- are left in the `client.messages.progress` table. Instead, it uses an
  --- ephemeron table (seen_messages) along with some heuristics to determine
  --- whether the message should be emitted. While this is somewhat slow, it's
  --- also being phased out; get_progress_messages() is deprecated in v0.10.0 and
  --- replaced by [vim.lsp.status()][lsp-status-pr], whose ring buffer gives
  --- consume semantics.
  ---
  --- Also note that this function only polls for _active_ clients; see below
  --- (`on_progress_message()`) for details.
  ---
  --- [get_progress_messages]: https://github.com/neovim/neovim/blob/v0.9.4/runtime/lua/vim/lsp/util.lua#L354-L385
  --- [lsp-status-pr]: https://github.com/neovim/neovim/pull/23958
  ---
  ---@protected
  ---@return ProgressMessage[] progress_messages
  function M.poll_for_messages()
    -- lsp_client_ids is not populated by `onp_progress_message()` handler,
    -- so we can only poll for active clients.
    local clients = vim.lsp.get_active_clients()

    if #clients == 0 then
      -- See issue #177
      logger.warn("No active LSP clients to poll from (see issue #177)")
      return {}
    end

    local messages = {}
    local to_remove = {}
    for _, client in ipairs(clients) do
      local client_name = string.format("%s (%s)", client.id, client.name)
      local count = 0
      logger.info("Polling messages from", client_name)
      for token, value in pairs(client.messages.progress) do
        count = count + 1
        local seen = seen_messages[value]
        if not seen                                -- brand new table
            or seen.message ~= value.message       -- message changed
            or seen.percentage ~= value.percentage -- percentage changed
            or seen.done ~= value.done then        -- progress completed
          local message = {
            token = token,
            title = value.title,
            message = value.message,
            percentage = value.done and nil or value.percentage,
            done = value.done or false,
            cancellable = value.cancellable or false,
            lsp_client = client,
          }
          logger.info("Got message from", client_name, ":", value)
          table.insert(messages, message)

          if value.done then
            table.insert(to_remove, { client = client, token = token })
          else
            seen_messages[value] = { message = value.message, percentage = value.percentage, done = value.done }
          end
        end
      end
      logger.info("Processed", count, "messages from", client_name)
    end

    for _, item in ipairs(to_remove) do
      item.client.messages.progress[item.token] = nil
    end

    return messages
  end

  --- Register callback for the `LspProgressUpdate` event (v0.8.0--v0.9.4).
  ---
  --- Unlike `LspProgress`, `LspProgressUpdate` is a [User] autocmd that does
  --- not carry information about which LSP client sent the progress message;
  --- it only conveys that some progress message has been sent.
  ---
  --- Thus, this handler does not populate the `lsp_client_ids` table; without
  --- this information, its corresponding `poll_for_messages()` only polls for
  --- messages from active LSP clients.
  ---
  ---@protected
  ---@param fn function
  ---@return number
  function M.on_progress_message(fn)
    return vim.api.nvim_create_autocmd({ "User" }, {
      pattern = { "LspProgressUpdate" },
      callback = fn,
      desc = "Fidget LSP progress handler",
    })
  end
end

return M

```

## lua/fidget/notification.lua

```lua
---@mod fidget.notification Notification subsystem
local notification          = {}
notification.model          = require("fidget.notification.model")
notification.window         = require("fidget.notification.window")
notification.view           = require("fidget.notification.view")
local poll                  = require("fidget.poll")
local logger                = require("fidget.logger")

--- Used to determine the identity of notification items and groups.
---@alias Key any

--- Second (level) parameter passed to |fidget.notification.notify|.
---
--- `string` indicates highlight group name; otherwise, `number` indicates
--- the |vim.log.levels| value (that will resolve to a highlight group as
--- determined by the |fidget.notification.Config|).
---@alias Level number|string

--- Third (opts) parameter passed to |fidget.notification.notify|.
---@class Options
---@field key           Key|nil       Replace existing notification item of the same key
---@field group         Key|nil       Group that this notification item belongs to
---@field annote        string|nil    Optional single-line title that accompanies the message
---@field hidden        boolean|nil   Whether this item should be shown
---@field ttl           number|nil    How long after a notification item should exist; pass 0 to use default value
---@field update_only   boolean|nil   If true, don't create new notification items
---@field skip_history  boolean|nil   If true, don't include in notifications history
---@field data          any|nil       Arbitrary data attached to notification item

--- Something that can be displayed in a |fidget.notification.Group|.
---
--- If false, this content is not rendered.
---
--- If a callable `function`, it is invoked every render cycle with the items
--- list; useful for rendering animations and other dynamic content.
---@alias Display string|false|fun(now: number, items: Item[]): (string|false|nil)

--- Used to configure the behavior of notification groups.
---
--- If both name and icon are nil, then no group header is rendered.
---
--- The `update_hook` function can be used to dynamically adjust fields of
--- a |fidget.notification.Item|, e.g., to set the `hidden` field according to
--- the message. If set to `false`, nothing is done when an item is updated.
---
--- Note that the actual |fidget.notification.default_config| defines a few
--- more defaults than what is documented here, which pertain to the fallback
--- used if the corresponding field in the `default` config table is `nil`.
---
---@class Config
---@field name              Display|nil   Name of the group
---@field icon              Display|nil   Icon of the group
---@field icon_on_left      boolean|nil   If `true`, icon is rendered on the left instead of right
---@field annote_separator  string|nil    Separator between message from annote; defaults to `" "`
---@field ttl               number|nil    How long a notification item should exist; defaults to `5`
---@field render_limit      number|nil    How many notification items to show at once
---@field group_style       string|nil    Style used to highlight group name; defaults to `"Title"`
---@field icon_style        string|nil    Style used to highlight icon; if nil, use `group_style`
---@field annote_style      string|nil    Default style used to highlight item annotes; defaults to `"Question"`
---@field debug_style       string|nil    Style used to highlight debug item annotes
---@field info_style        string|nil    Style used to highlight info item annotes
---@field warn_style        string|nil    Style used to highlight warn item annotes
---@field error_style       string|nil    Style used to highlight error item annotes
---@field debug_annote      string|nil    Default annotation for debug items
---@field info_annote       string|nil    Default annotation for info items
---@field warn_annote       string|nil    Default annotation for warn items
---@field error_annote      string|nil    Default annotation for error items
---@field priority          number|nil    Order in which group should be displayed; defaults to `50`
---@field skip_history      boolean|nil   Whether messages should be preserved in history
---@field update_hook       fun(item: Item)|false|nil   Called when an item is updated; defaults to `false`

--- Notification element containing a message and optional annotation.
---
---@class Item
---@field key           Key         Identity of this item (for in-place updates)
---@field content_key   Key         What to deduplicate items by (do not deduplicate if `nil`)
---@field message       string      Displayed message for the item
---@field annote        string|nil  Optional title that accompanies the message
---@field style         string      Style used to render the annote/title, if any
---@field hidden        boolean     Whether this item should be shown
---@field expires_at    number      What time this item should be removed; math.huge means never
---@field last_updated  number      What time this item was last updated
---@field skip_history  boolean     Whether this item should be included in history
---@field data          any|nil     Arbitrary data attached to notification item

--- A notification element in the notifications history.
---
---@class HistoryItem : Item
---@field removed       boolean     Whether this item is deleted
---@field group_key     Key         Key of the group this item belongs to
---@field group_name    string|nil  Title of the group this item belongs to
---@field group_icon    string|nil  Icon of the group this item belongs to
---@field last_updated  number      What time this item was last updated, in seconds since Jan 1, 1970

--- Filter options when querying for notifications history.
---
--- Note that filters are conjunctive; all specified predicates need to be true.
---
---@class HistoryFilter
---@field group_key       Key|nil     Items from this group
---@field before          number|nil  Only items last updated at least this long ago
---@field since           number|nil  Only items last updated at most this long ago
---@field include_removed boolean|nil Include items that have been removed (default: true)
---@field include_active  boolean|nil Include items that have not been removed (default: true)

--- The "model" (abstract state) of notifications.
---@type State
local state                 = {
  groups          = {},
  view_suppressed = false,
  removed         = {},
  removed_cap     = 128,
  removed_first   = 1,
}

--- Default notification configuration.
---
--- Exposed publicly because it might be useful for users to integrate for when
--- they are adding their own configs.
---
--- To see the default values, run:
---
--->vim
--- :lua print(vim.inspect(require("fidget.notification").default_config))
---<
---
--- Note that the default `update_hook` function performs a few book-keeping
--- tasks, e.g., calling |fidget.notification.set_content_key| to keep its
--- `content_key` up to date. You may want to do the same if writing your own;
--- check the source code to see what it's doing.
---
--- See also:~
---     |fidget.notification.Config|
---
---@type Config
notification.default_config = {
  name = "Notifications",
  icon = "❰❰",
  ttl = 5,
  group_style = "Title",
  icon_style = "Special",
  annote_style = "Question",
  debug_style = "Comment",
  info_style = "Question",
  warn_style = "WarningMsg",
  error_style = "ErrorMsg",
  debug_annote = "DEBUG",
  info_annote = "INFO",
  warn_annote = "WARN",
  error_annote = "ERROR",
  update_hook = function(item)
    notification.set_content_key(item)
  end,
}

--- Sets a |fidget.notification.Item|'s `content_key`, for deduplication.
---
--- This default implementation sets an item's `content_key` to its `message`,
--- appended with its `annote` (or a null byte if it has no `annote`), a rough
--- "hash" of its contents. You can write your own `update_hook` that "hashes"
--- the message differently, e.g., only considering the `message`, or taking the
--- `data` or style fields into account.
---
--- If you would like to disable message deduplication, don't call this
--- function, leaving the `content_key` field as `nil`. Assuming you're not
--- using the `update_hook` for anything else, you can achieve this by simply
--- the option to `false`, e.g.:
---
--->lua
--- { -- In options table
---   notification = {
---     configs = {
---       -- Opt out of deduplication by default, i.e., in default config
---       default = vim.tbl_extend("force", require('fidget.notification').default_config, {
---         update_hook = false,
---       },
---     },
---   },
--- }
---<
---
---@param item Item
function notification.set_content_key(item)
  item.content_key = item.message .. " " .. (item.annote and item.annote or string.char(0))
end

---@options notification [[
---@protected
--- Notification options
notification.options = {
  --- How frequently to update and render notifications
  ---
  --- Measured in Hertz (frames per second).
  ---
  ---@type number
  poll_rate = 10,

  --- Minimum notifications level
  ---
  --- Note that this filter only applies to notifications with an explicit
  --- numeric level (i.e., `vim.log.levels`).
  ---
  --- Set to `vim.log.levels.OFF` to filter out all notifications with an
  --- numeric level, or `vim.log.levels.TRACE` to turn off filtering.
  ---
  ---@type 0|1|2|3|4|5
  filter = vim.log.levels.INFO,

  --- Number of removed messages to retain in history
  ---
  --- Set to 0 to keep around history indefinitely (until cleared).
  ---
  ---@type number
  history_size = 128,

  --- Automatically override vim.notify() with Fidget
  ---
  --- Equivalent to the following:
  --->lua
  ---     fidget.setup({ --[[ options ]] })
  ---     vim.notify = fidget.notify
  ---<
  ---
  ---@type boolean
  override_vim_notify = false,

  --- How to configure notification groups when instantiated
  ---
  --- A configuration with the key `"default"` should always be specified, and
  --- is used as the fallback for notifications lacking a group key.
  ---
  --- To see the default config, run:
  --->vim
  ---     :lua print(vim.inspect(require("fidget.notification").default_config))
  ---<
  ---
  ---@type table<Key, Config>
  configs = { default = notification.default_config },

  --- Conditionally redirect notifications to another backend
  ---
  --- This option is useful for delegating notifications to another backend that
  --- supports features Fidget has not (yet) implemented.
  ---
  --- For instance, Fidget uses a single, shared buffer and window for rendering
  --- all notifications, so it lacks a per-notification `on_open` callback that
  --- can be used to, e.g., set the |filetype| for a specific notification.
  --- For such notifications, Fidget's default `redirect` delegates such
  --- notifications with an `on_open` callback to |nvim-notify| (if available).
  ---
  ---@type false|fun(msg: string|nil, level: Level|nil, opts: table|nil): (boolean|nil)
  redirect = function(msg, level, opts)
    if opts and opts.on_open then
      return require("fidget.integration.nvim-notify").delegate(msg, level, opts)
    end
  end,

  view = notification.view,
  window = notification.window,
}
---@options ]]

require("fidget.options").declare(notification, "notification", notification.options, function()
  -- Need to ensure that there is some sane default config.
  if not notification.options.configs.default then
    logger.warn("no default notification config specified; using default")
    notification.options.configs.default = notification.default_config
  end
  state.removed_cap = notification.options.history_size
  notification.reset()
end)

--- Send a notification to the Fidget notifications subsystem.
---
--- Can be used to override `vim.notify()`, e.g.,
--->lua
---     vim.notify = require("fidget.notification").notify
---<
---
---@param msg     string|nil  Content of the notification to show to the user.
---@param level   Level|nil   How to format the notification.
---@param opts    Options|nil Optional parameters (see |fidget.notification.Options|).
function notification.notify(msg, level, opts)
  if notification.options.redirect and notification.options.redirect(msg, level, opts) then
    logger.info(string.format("Redirected notification: %s", msg))
    return
  end

  if msg ~= nil and type(msg) ~= "string" then
    error("message: expected string, got " .. type(msg))
  end

  if level ~= nil and type(level) ~= "number" and type(level) ~= "string" then
    error("level: expected number | string, got " .. type(level))
  end

  if opts ~= nil and type(opts) ~= "table" then
    error("opts: expected table, got " .. type(opts))
  end

  if type(level) == "number" and level < notification.options.filter then
    logger.info(string.format("Filtered out notification (%s): %s", logger.fmt_level(level), msg))
    return
  end

  local now = poll.get_time()

  vim.schedule(function()
    notification.model.update(now, notification.options.configs, state, msg, level, opts)
    notification.poller:start_polling(notification.options.poll_rate)
  end)
end

--- Close the notification window.
---
--- Note that it the window will pop open again as soon as there is any reason
--- to (e.g., if another notification or LSP progress message is received).
---
--- To temporarily stop the window from opening, see |fidget.notification.suppress|.
---
---@return boolean closed_successfully Whether the window closed successfully.
function notification.close()
  return notification.window.guard(function()
    notification.window.close()
  end)
end

--- Clear active notifications.
---
--- If the given `group_key` is `nil`, then all groups are cleared. Otherwise,
--- only that notification group is cleared.
---
---@param group_key Key|nil  Which group to clear
function notification.clear(group_key)
  notification.model.clear(state, poll.get_time(), group_key)
  if #state.groups == 0 then
    notification.window.guard(notification.window.close)
  end
end

--- Clear notifications history, according to the specified filter.
---
---@param filter HistoryFilter|Key|nil  What to clear
function notification.clear_history(filter)
  if filter == nil then
    filter = {}
  elseif type(filter) ~= "table" then
    filter = { group_key = filter }
  end
  notification.model.clear_history(state, poll.get_time(), filter)
end

--- Reset notification subsystem state.
---
--- Note that this function does not set any Fidget notification window state,
--- in particular, the `x_offset`.
function notification.reset()
  notification.clear()
  notification.clear_history()
  notification.poller:reset_error() -- Clear error if previously encountered one
end

--- The poller for the notification subsystem.
---@protected
notification.poller = poll.Poller {
  name = "notification",
  poll = function(self)
    notification.model.tick(self:now(), state)

    -- TODO: if not modified, don't re-render
    local lines, width = notification.view.render(self:now(), state.groups)

    if #lines > 0 then
      if state.view_suppressed then
        return true
      end

      notification.window.guard(function()
        notification.window.set_lines(lines, width)
      end)
      return true
    else
      if state.view_suppressed then
        return false
      end

      -- If we could not close the window, keep polling, i.e., keep trying to close the window.
      return not notification.close()
    end
  end
}

--- Dynamically add, overwrite, or delete a notification configuration.
---
--- If config.name is not set and key is a string, uses the key as the name.
--- Inherits other missing keys from the default config.
---
---@param key       Key         Which config to set.
---@param config    Config|nil  What to set as config; nil to delete.
---@param overwrite boolean     Whether to overwrite existing config, if any.
---
---@see fidget.notification.Config
function notification.set_config(key, config, overwrite)
  if config == nil then
    notification.options.configs[key] = nil
    return
  end

  if overwrite or not notification.options.configs[key] then
    notification.options.configs[key] = vim.tbl_extend("keep", config, notification.options.configs.default)
    if not config.name and type(key) == "string" then
      notification.options.configs[key].name = key
    end
  end
end

--- Suppress whether the notification window is shown.
---
--- Pass `true` as argument to turn on suppression, or `false` to turn it off.
---
--- If no argument is given, suppression state is toggled.
---
---@param suppress boolean|nil Whether to suppress or toggle suppression
function notification.suppress(suppress)
  if suppress == nil then
    state.view_suppressed = not state.view_suppressed
  else
    state.view_suppressed = suppress
  end

  if state.view_suppressed then
    notification.close()
  end
end

--- Remove an item from a particular group.
---
---@param group_key Key
---@param item_key Key
---@return boolean successfully_removed
function notification.remove(group_key, item_key)
  return notification.model.remove(state, poll.get_time(), group_key, item_key)
end

--- Query notifications history, according to an optional filter.
---
--- Note that this function may return more than |fidget.options.history_size|
--- items, since it will also include current notifications, unless
--- `filter.include_active` is set to `false`.
---
---@param filter  HistoryFilter|Key|nil  options or group_key for filtering history
---@return        HistoryItem[] history
function notification.get_history(filter)
  if filter == nil then
    filter = {}
  elseif type(filter) ~= "table" then
    filter = { group_key = filter }
  end
  return notification.model.make_history(state, poll.get_time(), filter)
end

--- Show the notifications history in the |nvim_echo()| buffer.
---
---@param filter  HistoryFilter|Key|nil  options or group_key for filtering history
function notification.show_history(filter)
  local history = notification.get_history(filter)
  notification.view.echo_history(history)
end

--- Get list of active notification group keys.
---
---@return Key[] keys
function notification.group_keys()
  return vim.tbl_map(function(group) return group.key end, state.groups)
end

return notification

```

## lua/fidget/notification/view.lua

```lua
--- Helper methods used to render notification model elements into views.
---
--- TODO: partial/in-place rendering, to avoid building new strings.
local M = {}

local window = require("fidget.notification.window")

--- A list of highlighted tokens.
---@class NotificationLine : NotificationToken[]

--- A tuple consisting of some text and a stack of highlights.
---@class NotificationToken : {[1]: string, [2]: string[]}

local cache = {}

---@options notification.view [[
---@protected
--- Notifications rendering options
M.options = {
  --- Display notification items from bottom to top
  ---
  --- Setting this to true tends to lead to more stable animations when the
  --- window is bottom-aligned.
  ---
  ---@type boolean
  stack_upwards = true,

  --- Indent messages longer than a single line
  ---
  --- Example: ~
  --->
  ---   align message style INFO
  ---       looks like this
  ---         when reflowed
  ---
  ---    align annote style INFO
  ---       looks like this when
  ---                   reflowed
  ---<
  ---
  ---@type "message"|"annote"
  align = "message",

  --- Reflow (wrap) messages wider than notification window
  ---
  --- The various options determine how wrapping is handled mid-word.
  ---
  --- Example: ~
  --->
  ---       "hard" is reflo INFO
  ---         wed like this
  ---
  ---   "hyphenate" is ref- INFO
  ---       lowed like this
  ---
  ---   "ellipsis" is refl… INFO
  ---       …owed like this
  ---<
  ---
  --- If this option is set to false, long lines will simply be truncated.
  ---
  --- This option has no effect if |fidget.option.notification.window.max_width|
  --- is `0` (i.e., infinite).
  ---
  --- Annotes longer than this width on their own will not be wrapped.
  ---
  ---@type "hard"|"hyphenate"|"ellipsis"|false
  reflow = false,

  --- Separator between group name and icon
  ---
  --- Must not contain any newlines. Set to `""` to remove the gap between names
  --- and icons in all notification groups.
  ---
  ---@type string
  icon_separator = " ",

  --- Separator between notification groups
  ---
  --- Must not contain any newlines. Set to `false` to omit separator entirely.
  ---
  ---@type string|false
  group_separator = "--",

  --- Highlight group used for group separator
  ---
  ---@type string|false
  group_separator_hl = "Comment",

  --- Spaces to pad both sides of each non-empty line
  ---
  --- Useful for adding a visual gap between notification text and any buffer it
  --- may overlap with.
  ---
  ---@type integer
  line_margin = 1,

  --- How to render notification messages
  ---
  --- Messages that appear multiple times (have the same `content_key`) will
  --- only be rendered once, with a `cnt` greater than 1. This hook provides an
  --- opportunity to customize how such messages should appear.
  ---
  --- If this returns false or nil, the notification will not be rendered.
  ---
  --- See also:~
  ---     |fidget.notification.Config|
  ---     |fidget.notification.default_config|
  ---     |fidget.notification.set_content_key|
  ---
  ---@type fun(msg: string, cnt: number): (string|false|nil)
  render_message = function(msg, cnt) return cnt == 1 and msg or string.format("(%dx) %s", cnt, msg) end,
}
---@options ]]

require("fidget.options").declare(M, "notification.view", M.options, function()
  cache = {} -- clear cache

  vim.api.nvim_create_autocmd({ "UIEnter", "UILeave" }, {
    group = vim.api.nvim_create_augroup("fidget_multigrid_ui", { clear = true }),
    callback = function() M.is_multigrid_ui(true) end,
  })
end)

--- True when using GUI clients like neovide. Updated on UIEnter/UILeave.
---@type boolean | nil
local saw_multigrid_ui = nil

function M.is_multigrid_ui(force)
  if saw_multigrid_ui == nil or force then
    saw_multigrid_ui = false
    for _, ui in ipairs(vim.api.nvim_list_uis()) do
      if ui.ext_multigrid then
        saw_multigrid_ui = true
        break
      end
    end
  end
  return saw_multigrid_ui
end

---  Whether nr is a codepoint representing whitespace.
---
---@param s string
---@param index integer
---@return boolean
local function whitespace(s, index)
  -- Same heuristic as vim.fn.trim(): <= 32 includes all ASCII whitespace
  -- (as well as other control chars, which we don't care about).
  -- Note that 160 is the unicode no-break space but we don't want to break on
  -- that anyway.
  return vim.fn.strgetchar(s, index) <= 32
end

--- The displayed width of some strings.
---
--- A simple wrapper around vim.fn.strwidth(), accounting for tab characters
--- manually.
---
--- We call this instead of vim.fn.strdisplaywidth() because that depends on
--- the state and size of the current window and buffer, which could be
--- anywhere.
---@param ... string
---@return integer len
local function strwidth(...)
  local w = 0
  for _, s in ipairs({ ... }) do
    w = w + vim.fn.strwidth(s) +
        vim.fn.count(s, "\t") * math.max(0, window.options.tabstop - 1)
  end
  return w
end

---@return integer len
local function line_margin()
  return 2 * M.options.line_margin
end

--- The displayed width of some strings, accounting for line_margin.
---@param ... string
---@return integer len
local function line_width(...)
  local w = strwidth(...)
  return w == 0 and w or w + line_margin()
end

---@param text string the text in this token
---@param ... string  highlights to apply to text
---@return NotificationToken
local function Token(text, ...)
  if M.is_multigrid_ui() then
    return { text, { ... } }
  end
  return { text, { window.no_blend_hl, ... } }
end

---@param ... NotificationToken
---@return NotificationLine
local function Line(...)
  if select("#", ...) == 0 then
    return {}
  end
  local margin = Token(string.rep(" ", M.options.line_margin))
  -- ... only expands to all args in last position of table
  local line = { margin, ... }
  line[#line + 1] = margin
  return line
end

---@return NotificationLine[]|nil lines
---@return integer                width
function M.render_group_separator()
  local line = M.options.group_separator
  if not line then
    return nil, 0
  end

  if cache.group_sep == nil then
    cache.group_sep = { Line(Token(line, M.options.group_separator_hl)) }
    cache.width = line_width(line)
  end
  return cache.group_sep, cache.width
end

--- Render the header of a group, containing group name and icon.
---
---@param   now   number    timestamp of current render frame
---@param   group Group     group whose header we should render
---@return  NotificationLine[]|nil group_header
---@return  integer                width
function M.render_group_header(now, group)
  local group_name = group.config.name
  if type(group_name) == "function" then
    group_name = group_name(now, group.items)
  end

  local group_icon = group.config.icon
  if type(group_icon) == "function" then
    group_icon = group_icon(now, group.items)
  end

  local name_tok = group_name and Token(
    group_name, group.config.group_style or "Title"
  )
  local icon_tok = group_icon and Token(
    group_icon, group.config.icon_style or group.config.group_style or "Title"
  )

  if name_tok and icon_tok then
    ---@cast group_name string
    ---@cast group_icon string
    if cache.icon_sep == nil then
      cache.icon_sep = Token(M.options.icon_separator)
    end
    local sep_tok = cache.icon_sep
    local width = line_width(group_name, group_icon, M.options.icon_separator)
    if group.config.icon_on_left then
      return { Line(icon_tok, sep_tok, name_tok) }, width
    else
      return { Line(name_tok, sep_tok, icon_tok) }, width
    end
  elseif name_tok then
    ---@cast group_name string
    return { Line(name_tok) }, line_width(group_name)
  elseif icon_tok then
    ---@cast group_icon string
    return { Line(icon_tok) }, line_width(group_icon)
  else
    -- No group header to render
    return nil, 0
  end
end

---@param items Item[]
---@return Item[] deduped
---@return table<any, integer> counts
function M.dedup_items(items)
  local deduped, counts = {}, {}
  for _, item in ipairs(items) do
    local key = item.content_key or item
    if counts[key] then
      counts[key] = counts[key] + 1
    else
      counts[key] = 1
      table.insert(deduped, item)
    end
  end
  return deduped, counts
end

--- Render a notification item, containing message and annote.
---
---@param item   Item
---@param config Config
---@param count  number
---@return NotificationLine[]|nil lines
---@return integer                max_width
function M.render_item(item, config, count)
  if item.hidden then
    return nil, 0
  end

  local msg = M.options.render_message(item.message, count)
  if not msg then
    -- Don't render any lines for nil messages
    return nil, 0
  end

  local lines, item_width = {}, 0

  local ann_tok = item.annote and Token(item.annote, item.style)
  local sep_tok = Token(config.annote_separator or " ")

  -- How much space is available to message lines
  local msg_width = window.max_width()
      - line_margin() -- adjusted for line margin
      - 1             -- adjusted for ext_mark margin

  local presplit_char, postsplit_char = nil, nil
  if M.options.reflow == "hyphenate" then
    presplit_char = "-"
  elseif M.options.reflow == "ellipsis" then
    presplit_char = "…"
    postsplit_char = "…"
  end

  if ann_tok and msg_width ~= math.huge and M.options.reflow then
    -- If we need annote, adjust remaining available width for message line(s)
    local ann_width = strwidth(sep_tok[1], ann_tok[1])
    if ann_width > msg_width then
      -- No room for annote + item line. Put annote on line of its own.
      table.insert(lines, Line(ann_tok))
      item_width = line_width(ann_tok[1])
      -- Pretend there was no annote to begin with.
      ann_tok = nil
    else
      -- Reduce available space for message line(s); that will get printed next
      -- to annote and sep in first iteration of loop below.
      msg_width = msg_width - ann_width
    end
  end

  local function insert(line)
    if ann_tok then
      -- Need to emite annote token in this line
      if window.options.h_align == "left" then
        table.insert(lines, Line(ann_tok, sep_tok, line))
      else
        table.insert(lines, Line(line, sep_tok, ann_tok))
      end
      item_width = math.max(item_width, line_width(line[1], sep_tok[1], ann_tok[1]))

      if M.options.align == "annote" then
        -- Refund available msg_width with length of annote + sepeparator
        msg_width, ann_tok = msg_width + strwidth(sep_tok[1], ann_tok[1]), nil
      else -- M.options.align == "message"
        -- Replace annote token with equivalent width of space
        ann_tok = Token(string.rep(" ", strwidth(ann_tok[1])))
      end
    else
      table.insert(lines, Line(line))
      item_width = math.max(item_width, line_width(line[1]))
    end
  end

  for whole_line in vim.gsplit(msg, "\n", { plain = true, trimempty = true }) do
    local lwidth = strwidth(whole_line)
    if msg_width >= lwidth then
      -- The entire line fits into the available space; insert it as is.
      -- Note that we do not trim it either.
      insert(Token(whole_line))
    elseif not M.options.reflow then
      -- If the message is wider than available space but we are explicitly
      -- asked not to reflow, then just truncate it.
      insert(Token(vim.fn.strcharpart(whole_line, 0, msg_width, true)))
    else
      local split_begin, postsplit = 0, nil
      whole_line = vim.fn.trim(whole_line)
      while lwidth > 0 do
        local split_len, presplit = msg_width, nil
        if postsplit then
          split_len = split_len - 1
        end

        if lwidth > split_len
            and not whitespace(whole_line, split_begin + split_len)
            and not whitespace(whole_line, split_begin + split_len - 1)
        then
          if whitespace(whole_line, split_begin + split_len - 2) then
            -- Avoid "split w/ord"
            split_len = split_len - 1
          elseif presplit_char then
            if whitespace(whole_line, split_begin + split_len - 3) then
              -- Avoid "split w-/ord"
              split_len = split_len - 2
            else
              split_len = split_len - 1
              presplit = presplit_char
            end
          end
        end

        local line = vim.fn.strcharpart(whole_line, split_begin, split_len, true)
        line = vim.fn.trim(line)
        if postsplit then
          line = postsplit .. line
        end
        if presplit then
          line = line .. presplit
          postsplit = postsplit_char
        else
          postsplit = nil
        end
        insert(Token(line))
        split_begin = split_begin + split_len
        lwidth = lwidth - split_len
      end
    end
  end

  if #lines == 0 then
    if ann_tok then
      -- The message is an empty string, but there's an annotation to render.
      return { Line(ann_tok) }, line_width(item.annote)
    else
      -- Don't render empty messages
      return nil, 0
    end
  else
    return lines, item_width
  end
end

--- Render notifications into lines and highlights.
---
---@param now number timestamp of current render frame
---@param groups Group[]
---@return NotificationLine[] lines
---@return integer width
function M.render(now, groups)
  ---@type NotificationLine[][]
  local chunks = {}
  local max_width = 0

  for idx, group in ipairs(groups) do
    if idx ~= 1 then
      local sep, sep_width = M.render_group_separator()
      if sep then
        table.insert(chunks, sep)
        max_width = math.max(max_width, sep_width)
      end
    end

    local hdr, hdr_width = M.render_group_header(now, group)
    if hdr then
      table.insert(chunks, hdr)
      max_width = math.max(max_width, hdr_width)
    end

    local items, counts = M.dedup_items(group.items)
    for i, item in ipairs(items) do
      if group.config.render_limit and i > group.config.render_limit then
        -- Don't bother rendering the rest (though they still exist)
        break
      end

      local it, it_width = M.render_item(item, group.config, counts[item.content_key or item])
      if it then
        table.insert(chunks, it)
        max_width = math.max(max_width, it_width)
      end
    end
  end

  local start, stop, step
  if M.options.stack_upwards then
    start, stop, step = #chunks, 1, -1
  else
    start, stop, step = 1, #chunks, 1
  end

  local lines = {}
  for i = start, stop, step do
    for _, line in ipairs(chunks[i]) do
      table.insert(lines, line)
    end
  end
  return lines, max_width
end

--- Display notification items in Neovim messages.
---
--- TODO(j-hui): this is not very configurable, but I'm not sure what options to
--- expose to strike a balance between flexibility and simplicity. Then again,
--- nothing done here is "special"; the user can easily (and is encouraged to)
--- write a custom `echo_history()` by consuming the results of `get_history()`.
---
---@param items HistoryItem[]
function M.echo_history(items)
  for _, item in ipairs(items) do
    local is_multiline_msg = string.find(item.message, "\n") ~= nil

    local chunks = {}

    table.insert(chunks, { vim.fn.strftime("%c", item.last_updated), "Comment" })

    -- if item.group_icon and #item.group_icon > 0 then
    --   table.insert(chunks, { " ", "MsgArea" })
    --   table.insert(chunks, { item.group_icon, "Special" })
    -- end

    if item.group_name and #item.group_name > 0 then
      table.insert(chunks, { " ", "MsgArea" })
      table.insert(chunks, { item.group_name, "Special" })
    end

    table.insert(chunks, { " | ", "Comment" })

    if item.annote and #item.annote > 0 then
      table.insert(chunks, { item.annote, item.style })
    end

    if is_multiline_msg then
      table.insert(chunks, { "\n", "MsgArea" })
    else
      table.insert(chunks, { " ", "MsgArea" })
    end

    table.insert(chunks, { item.message, "MsgArea" })

    if is_multiline_msg then
      table.insert(chunks, { "\n", "MsgArea" })
    end

    vim.api.nvim_echo(chunks, false, {})
  end
end

return M

```

## lua/fidget/notification/window.lua

```lua
--- This module encapsulates state and helper functions associated with managing
--- nvim buffers and windows that are used to display notifications.
---
--- Not part of the public API (but do what you want with it).
---
--- If this framework were to be expanded to support multiple concurrent
--- windows, this module's contents would need to be cloned.
---
--- Note that for now, it only supports editor-relative floats, though some code
--- ported from the legacy version still supports window-relative floats.
local M                         = {}
local logger                    = require("fidget.logger")

---@options notification.window [[
---@protected
--- Notifications window options
M.options                       = {
  --- Base highlight group in the notification window
  ---
  --- Used by any Fidget notification text that is not otherwise highlighted,
  --- i.e., message text.
  ---
  --- Note that we use this blanket highlight for all messages to avoid adding
  --- separate highlights to each line (whose lengths may vary).
  ---
  --- Set to empty string to keep your theme defaults.
  ---
  --- With `winblend` set to anything less than `100`, this will also affect the
  --- background color in the notification box area (see `winblend` docs).
  ---
  ---@type string
  normal_hl = "Comment",

  --- Background color opacity in the notification window
  ---
  --- Note that the notification window is rectangular, so any cells covered by
  --- that rectangular area is affected by the background color of `normal_hl`.
  --- With `winblend` set to anything less than `100`, the background of
  --- `normal_hl` will be blended with that of whatever is underneath,
  --- including, e.g., a shaded `colorcolumn`, which is usually not desirable.
  ---
  --- However, if you would like to display the notification window as its own
  --- "boxed" area (especially if you are using a non-"none" `border`), you may
  --- consider setting `winblend` to something less than `100`.
  ---
  --- See also: options for |nvim_open_win()|
  ---
  ---@type number
  winblend = 100,

  --- Border around the notification window
  ---
  --- See also: options for |nvim_open_win()|
  ---
  ---@type "none"|"single"|"double"|"rounded"|"solid"|"shadow"|string[]
  border = "none",

  --- Highlight group for notification window border
  ---
  --- Set to empty string to keep your theme's default `FloatBorder` highlight.
  ---
  ---@type string
  border_hl = "",

  --- Stacking priority of the notification window
  ---
  --- Note that the default priority for Vim windows is 50.
  ---
  --- See also: options for |nvim_open_win()|
  ---
  ---@type number
  zindex = 45,

  --- Maximum width of the notification window
  ---
  --- `0` means no maximum width.
  ---
  --- Non-integral numbers between `0` and `1` mean a fraction of the editor
  --- width, e.g., `0.5` for half of the editor.
  ---
  ---@type number
  max_width = 0,

  --- Maximum height of the notification window
  ---
  --- `0` means no maximum height.
  ---
  ---@type integer
  max_height = 0,

  --- Padding from right edge of window boundary
  ---
  ---@type integer
  x_padding = 1,

  --- Padding from bottom edge of window boundary
  ---
  ---@type integer
  y_padding = 0,

  --- How to align the notification window vertically
  ---
  ---@type "top"|"bottom"|"avoid_cursor"
  align = "bottom",

  --- How to align the notification window horizontally
  ---
  ---@type "right"|"left"
  h_align = "right",

  --- What the notification window position is relative to
  ---
  --- See also: options for |nvim_open_win()|
  ---
  ---@type "editor"|"win"
  relative = "editor",

  --- Width of each tab character in the notification window
  ---
  ---@type number
  tabstop = 8,

  --- Filetypes the notification window should avoid
  ---
  --- Example: ~
  --->lua
  ---   avoid = { "aerial", "NvimTree", "nerdtree", "neotest-summary" }
  ---<
  ---@type string[]
  avoid = {},
}
---@options ]]

require("fidget.options").declare(M, "notification.window", M.options)

--- The name of the highlight group that Fidget uses to prevent winblend from
--- "bleeding" the main editor window into the notification window.
M.no_blend_hl = "FidgetNoBlend"

--- Local state maintained by this module.
---
--- If this framework were ever extended to support multiple concurrent windows,
--- this table's contents would need to be cloned.
local state = {
  --- ID of the buffer that notifications are rendered to.
  ---
  ---@type number|nil
  buffer_id = nil,

  --- ID of the window that the notification buffer is shown in.
  ---
  ---@type number|nil
  window_id = nil,

  --- ID of the namespace on which highlights are created.
  ---
  ---@type number|nil
  namespace_id = nil,
}

--- Reload namespace highlights on colorscheme change
---
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    if state.window_id then
      M.set_namespace_hl()
    end
  end
})

--- Suppress errors that may occur while render windows.
---
--- The E523 error (Not allowed here) happens when 'secure' operations
--- (including buffer or window management) are invoked while textlock is held
--- or the Neovim UI is blocking. See #68.
---
--- Also ignore E11 (Invalid in command-line window), which is thrown when
--- Fidget tries to close the window while a command-line window is focused.
--- See #136.
---
--- This utility provides a workaround to simply suppress the error.
--- All other errors will be re-thrown.
---
--- (Thanks @wookayin and @0xAdk!)
---
---@param callable fun()
---@return boolean suppressed_error
function M.guard(callable)
  local whitelist = {
    "E11: Invalid in command%-line window",
    "E523: Not allowed here",
    "E565: Not allowed to change",
  }

  local ok, err = pcall(callable)
  if ok then
    return true
  end

  if type(err) ~= "string" then
    -- Don't know how to deal with this kind of error object
    error(err)
  end

  for _, msg in ipairs(whitelist) do
    if string.find(err, msg) then
      return false
    end
  end

  error(err)
end

---@param winnr integer
---@return boolean avoid whether to avoid this window
local function should_avoid(winnr)
  if vim.api.nvim_win_get_config(winnr).relative ~= "" then
    -- Always avoid floating windows
    return true
  end
  local bufnr = vim.api.nvim_win_get_buf(winnr)
  local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  return ft == "fidget" or vim.tbl_contains(M.options.avoid, ft)
end

---@return integer height of the editor area, excludes statusline and tabline
local function get_editor_height()
  local statusline_height = 0
  local laststatus = vim.opt.laststatus:get()
  if laststatus == 2 or laststatus == 3
      or (laststatus == 1 and #vim.api.nvim_tabpage_list_wins(0) > 1)
  then
    statusline_height = 1
  end

  return vim.opt.lines:get() - (statusline_height + vim.opt.cmdheight:get())
end

---@return integer width of the editor area, including signcolumn and foldcolumn
local function get_editor_width()
  return vim.opt.columns:get()
end

---@param winnr integer
---@return integer effective_height of the window, excluding winbar
local function get_effective_win_height(winnr)
  local height = vim.api.nvim_win_get_height(0)
  if vim.fn.exists("+winbar") > 0 and vim.opt.winbar:get() ~= "" then
    -- When winbar is set, effective win height is reduced by 1 (see :help winbar)
    return height - 1
  end
  return height
end

---@return integer tabline_height
local function get_tabline_height()
  local stal = vim.opt.showtabline:get()
  if stal == 2 or (stal == 1 and #vim.api.nvim_list_tabpages() > 1) then
    -- tabline is shown; height is 1
    return 1
  else
    return 0
  end
end

--- Compute the max width of the notification window.
---
---@return integer
function M.max_width()
  if M.options.max_width <= 0 then
    return math.huge
  end

  if M.options.max_width < 1 then
    local width = vim.opt.columns:get()
    return math.ceil(width * M.options.max_width)
  end

  return math.max(4, math.floor(M.options.max_width))
end

---@param cursor_row integer current line number of cursor
---@param max_rows integer total number of rows
---@return boolean whether to align bottom
local function should_align_bottom(cursor_row, max_rows)
  if M.options.align == "bottom" then
    return true
  elseif M.options.align == "top" then
    return false
  else -- M.options.align == "avoid_cursor"
    return cursor_row <= (max_rows / 2)
  end
end

---@return boolean whether to align left
local function should_align_left()
  return M.options.h_align == "left"
end

--- Look for "best" window to align notification window with.
---
--- If none of the windows need to be avoided, then we should end up either
--- with the SE (align_bottom) or NE (not align_bottom) corner of the editor.
---
---@param row_max integer
---@param align_bottom boolean
---@param align_left boolean
---@return integer row
---@return integer col
local function search_for_editor_anchor(row_max, align_bottom, align_left)
  -- Use -math.huge as sentinel for unset col regardless of alignment
  local row, col
  if align_bottom then
    row, col = -math.huge, -math.huge
  else
    row, col = math.huge, -math.huge
  end

  if #M.options.avoid > 0 then
    -- Search for row/col of "best" window to align notification window with,
    -- while avoiding windows whose filetype is blacklisted by M.options.avoid.
    local wins = vim.api.nvim_tabpage_list_wins(0)
    for _, win in ipairs(wins) do
      if not should_avoid(win) then
        local pos = vim.api.nvim_win_get_position(win)
        if align_bottom then
          if align_left then
            -- Get SW corner of window
            local h = vim.api.nvim_win_get_height(win)
            local r, c = pos[1] + h, pos[2]
            if r - c > row - col then
              row, col = r, c
            end
          else
            -- Get SE corner of window
            local h, w = vim.api.nvim_win_get_height(win), vim.api.nvim_win_get_width(win)
            local r, c = pos[1] + h, pos[2] + w
            if r + c > row + col then
              row, col = r, c
            end
          end
        else -- not align_bottom
          if align_left then
            -- Get NW corner of window
            local r, c = pos[1], pos[2]
            if -r - c > -row - col then
              row, col = r, c
            end
          else
            -- Get NE corner of window
            local w = vim.api.nvim_win_get_width(win)
            local r, c = pos[1], pos[2] + w
            if -r + c > -row + col then
              row, col = r, c
            end
          end
        end
      end
    end
  end

  -- If col is still the sentinel (-math.huge), no valid window was found.
  -- Fall back to the editor corner.
  if col < 0 then
    if align_left then
      col = 0
    else
      col = get_editor_width()
    end
    row = align_bottom and row_max or get_tabline_height()
  end
  return row, col
end

--- Compute the row, col, anchor for |nvim_open_win()| to align the window.
---
---@return number           row
---@return number           col
---@return ("NE"|"SE"|"NW"|"SW")      anchor
---@return ("editor"|"win") relative
function M.get_window_position()
  local row_max, align_bottom, col, row, relative
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - vim.fn.line("w0")
  local align_left = should_align_left()

  if M.options.relative == "win" and not should_avoid(0) then
    relative = "win"
    row_max = get_effective_win_height(0)
    align_bottom = should_align_bottom(cursor_row, row_max)
    row = align_bottom and row_max or 0
    col = align_left and 0 or vim.api.nvim_win_get_width(0)
  else -- M.options.relative == "editor", or we need to avoid current window
    relative = "editor"
    row_max = get_editor_height()
    local window_pos = vim.api.nvim_win_get_position(0)
    align_bottom = should_align_bottom(window_pos[1] + cursor_row, row_max)
    row, col = search_for_editor_anchor(row_max, align_bottom, align_left)
  end

  if align_left then
    col = col + M.options.x_padding
  else
    col = math.max(0, col - M.options.x_padding)
  end
  row = align_bottom
      and math.max(0, row - M.options.y_padding)
      or math.min(row_max, row + M.options.y_padding)
  return row, col, (align_bottom and "S" or "N") .. (align_left and "W" or "E"), relative
end

--- Set local options on a window.
---
--- Workaround for nvim bug where nvim_win_set_option "leaks" local options to
--- windows created afterwards.
---
--- (Thanks @sindrets!)
---
--- See also:
--- * https://github.com/b0o/incline.nvim/issues/4
--- * https://github.com/neovim/neovim/issues/18283
--- * https://github.com/neovim/neovim/issues/14670
---
---@param window_id number  window to on which options should be set
---@param opts      table   local options to set
function M.win_set_local_options(window_id, opts)
  vim.api.nvim_win_call(window_id, function()
    for opt, val in pairs(opts) do
      local arg
      if type(val) == "boolean" then
        arg = (val and "" or "no") .. opt
      else
        arg = opt .. "=" .. val
      end
      vim.cmd("setlocal " .. arg)
    end
  end)
end

--- Get the notification buffer ID; create it if it doesn't already exist.
---
---@return number buffer_id
function M.get_buffer()
  if state.buffer_id == nil or not vim.api.nvim_buf_is_valid(state.buffer_id) then
    -- Create an unlisted (1st param) scratch (2nd param) buffer
    state.buffer_id = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", "fidget", { buf = state.buffer_id })
    -- We set this to a known value to ensure we correctly account for the width
    -- of tab chars while calling strwidth() in notification.view.strwidth().
    vim.api.nvim_set_option_value("tabstop", M.options.tabstop, { buf = state.buffer_id })
  end
  return state.buffer_id
end

--- Get the notification window ID; create it if it doesn't already exist.
---
--- Note that this will show the window as well, which is why it requires
--- a bunch of parameters that dictate how the window should be shown.
---
--- This also has the side effect of creating a notification buffer if it
--- doesn't already exist, associating it with the window.
---
--- Returns nil if Fidget window could not be created (e.g., because editor is
--- too small to show Fidget).
---
---@param row     number
---@param col     number
---@param anchor  ("NW"|"NE"|"SW"|"SE")
---@param relative ("editor"|"win")
---@param width   number
---@param height  number
---@return number|nil window_id
function M.get_window(row, col, anchor, relative, width, height)
  -- Clamp width and height to dimensions of editor and user specification.
  local editor_width, editor_height = get_editor_width(), get_editor_height()
  editor_width = math.max(0, editor_width - 4) -- HACK: guess width of signcolumn etc.

  if editor_width < 4 or editor_height < 4 then
    logger.info("Editor window is too small to display Fidget:", editor_width, "x", editor_height)
    M.close()
    return nil
  end

  -- Rendering with ext_marks causes lines to appear 1 character wider because
  -- the mark begins _after_ eol
  width = width + 1
  width = math.min(width, editor_width, M.max_width())

  height = math.min(height, editor_height)
  if M.options.max_height > 0 then
    height = math.min(height, M.options.max_height)
  end

  local valid = state.window_id and vim.api.nvim_win_is_valid(state.window_id)

  -- Window exists but is in a different tabpage
  if valid
      and vim.api.nvim_win_get_tabpage(state.window_id) ~= vim.api.nvim_get_current_tabpage()
      and not pcall(vim.api.nvim_win_set_config, state.window_id, { win = vim.api.nvim_get_current_win() })
  then
    -- manually close and so recreate before https://github.com/neovim/neovim/pull/35816
    vim.api.nvim_win_close(state.window_id, true)
    valid = nil
    state.window_id = nil
  end

  if not valid then
    -- Create window to display notifications buffer, but don't enter (2nd param)
    state.window_id = vim.api.nvim_open_win(M.get_buffer(), false, {
      relative = relative,
      width = width,
      height = height,
      row = row,
      col = col,
      anchor = anchor,
      focusable = false,
      style = "minimal",
      border = M.options.border,
      zindex = M.options.zindex,
      noautocmd = true,
    })
    vim.api.nvim_win_set_hl_ns(state.window_id, M.get_namespace())
  else
    -- Window is already created; reposition it in case anything has changed.
    vim.api.nvim_win_set_config(state.window_id, {
      relative = relative,
      width = width,
      height = height,
      row = row,
      col = col,
      anchor = anchor,
    })
  end

  M.win_set_local_options(state.window_id, {
    winblend = M.options.winblend,
  })
  return state.window_id
end

--- Setup highlight groups used to apply highlights inside window
---
function M.set_namespace_hl()
  local base_normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })

  local normal_hl = base_normal_hl
  if M.options.normal_hl ~= "" and M.options.normal_hl ~= "Normal" then
    -- Options say that we should use something else as Normal
    normal_hl = vim.api.nvim_get_hl(0, { name = M.options.normal_hl })

    -- A non-Normal highlight might lack a background, so we explicitly copy
    -- it over from the actual normal highlight group
    normal_hl.bg = normal_hl.bg or base_normal_hl.bg
  end

  if state.namespace_id == nil then
    state.namespace_id = vim.api.nvim_create_namespace("fidget-window")
  end
  -- For some reason, these are annotated as distinct types even though the
  -- documentation for nvim_get_hl() indicates they share the same schema.
  ---@diagnostic disable-next-line: cast-type-mismatch
  ---@cast normal_hl vim.api.keyset.highlight

  vim.api.nvim_set_hl(state.namespace_id, "Normal", normal_hl)
  vim.api.nvim_set_hl(state.namespace_id, "NormalNC", normal_hl)

  normal_hl.blend = 0
  vim.api.nvim_set_hl(state.namespace_id, M.no_blend_hl, normal_hl)

  local border_hl = vim.api.nvim_get_hl(0, {
    name = M.options.border_hl == "" and "FloatBorder" or M.options.border_hl,
  })

  ---@diagnostic disable-next-line: cast-type-mismatch
  ---@cast border_hl vim.api.keyset.highlight

  -- Explicitly ignore FloatBorder background and use background from whatever
  -- was determined to be "normal", which is *probably* the right thing to do.
  border_hl.bg = normal_hl.bg

  vim.api.nvim_set_hl(state.namespace_id, "FloatBorder", border_hl)
end

--- Get a namespace ID or creates an existing one if it doesn't exist
---
---@return number namespace_id
function M.get_namespace()
  if state.namespace_id == nil then
    M.set_namespace_hl()
  end
  return state.namespace_id
end

--- Show the notification window (and its buffer contents), editor-relative.
---
--- Returns nil if Fidget window could not be created (e.g., because editor is
--- too small to show Fidget).
---
---@param height  integer
---@param width   integer
---@return number|nil window_id
function M.show(height, width)
  local row, col, anchor, relative = M.get_window_position()
  return M.get_window(row, col, anchor, relative, width, height)
end

--- Replace the set of lines in the Fidget window, right-justify them, and apply
--- highlights.
---
---
---@param lines       NotificationLine[]  lines to place into buffer
---@param width       integer             width of longest line
function M.set_lines(lines, width)
  local buffer_id = M.get_buffer()
  local namespace_id = M.get_namespace()
  local align_left = should_align_left()

  -- Clear previous highlights
  vim.api.nvim_buf_clear_namespace(buffer_id, namespace_id, 0, -1)

  -- Prepare empty lines for extmarks
  local empty_lines = vim.tbl_map(function() return "" end, lines)
  vim.api.nvim_buf_set_lines(buffer_id, 0, -1, false, empty_lines)

  for iline, line in ipairs(lines) do
    if vim.fn.has("nvim-0.11.0") == 1 then
      vim.api.nvim_buf_set_extmark(buffer_id, namespace_id, iline - 1, 0, {
        virt_text = line,
        virt_text_pos = align_left and "eol" or "eol_right_align",
      })
    else
      local len = 0
      for _, tok in ipairs(line) do
        len = len + vim.fn.strwidth(tok[1]) +
            vim.fn.count(tok[1], "\t") * math.max(0, M.options.tabstop - 1)
      end
      local padded
      if align_left then
        padded = line
      else
        local pad_width = math.max(0, width - len)
        if pad_width > 0 then
          padded = { { string.rep(" ", pad_width), {} } }
          for _, tok in ipairs(line) do
            table.insert(padded, tok)
          end
        else
          padded = line
        end
      end
      vim.api.nvim_buf_set_extmark(buffer_id, namespace_id, iline - 1, 0, {
        virt_text = padded,
        virt_text_pos = "eol",
      })
    end
  end
  M.show(vim.api.nvim_buf_line_count(buffer_id), width)
end

--- Close the Fidget window and associated buffers.
function M.close()
  if state.namespace_id ~= nil then
    if state.buffer_id ~= nil and vim.api.nvim_buf_is_valid(state.buffer_id) then
      vim.api.nvim_buf_clear_namespace(state.buffer_id, state.namespace_id, 0, -1)
    end
    state.namespace_id = nil
  end

  if state.window_id ~= nil then
    if vim.api.nvim_win_is_valid(state.window_id) then
      vim.api.nvim_win_close(state.window_id, true)
    end
    state.window_id = nil
  end

  if state.buffer_id ~= nil then
    if vim.api.nvim_buf_is_valid(state.buffer_id) then
      vim.api.nvim_buf_delete(state.buffer_id, { force = true })
    end
    state.buffer_id = nil
  end
end

return M

```

## lua/fidget/logger.lua

```lua
--- Adapted from https://www.github.com/tjdevries/vlog.nvim
local M = {}

local PLUGIN_PATH_PATTERN = "(/lua/fidget.+)"

---@options logger [[
---@protected
--- Logging options
M.options = {
  --- Whether to enable file logging
  ---
  --- Set to `false` to disable all file I/O from the logger.
  ---
  ---@type boolean
  enable = true,

  --- Minimum logging level
  ---
  --- Set to `vim.log.levels.OFF` to disable logging, or `vim.log.levels.TRACE`
  --- to enable all logging.
  ---
  --- Note that this option only filters logging (useful for debugging), and is
  --- different from `notification.filter`, which filters `notify()` messages.
  ---
  ---@type 0|1|2|3|4|5
  level = vim.log.levels.WARN,

  --- Maximum log file size, in KB
  ---
  --- If this option is set to `false`, the log file will be let to grow
  --- indefinitely.
  ---
  --- When the log file exceeds this size, it is backed up with suffix `.bak`,
  --- overwriting any possible previous backup. Thus, the maximum on-disk
  --- footprint of Fidget logs is approximately twice `logger.max_size`.
  --- If you would like to retain the backup log, copy it manually.
  ---
  --- Note that there is a possible race condition when two concurrent Neovim
  --- processes both try to back up the log file. Thus, a fresh backup log file
  --- may be clobbered by a concurrent Neovim process, before you have a chance
  --- to back move it somewhere safe for later inspection. So, when debugging
  --- Fidget, run only one instance of Neovim, or set this option to `false`.
  ---
  ---@type number | false
  max_size = 10000,

  --- Limit the number of decimals displayed for floats
  ---
  ---@type number
  float_precision = 0.01,

  --- Where Fidget writes its logs to
  ---
  --- Using `vim.fn.stdpath("cache")`, the default path usually ends up at
  --- `~/.cache/nvim/fidget.nvim.log`.
  ---
  ---@type string
  path = string.format("%s/fidget.nvim.log", vim.fn.stdpath("cache")),
}
---@options ]]

require("fidget.options").declare(M, "logger", M.options, function()
  if not M.options.enable then
    return
  end

  -- Create directory where log will reside
  vim.fn.mkdir(vim.fn.fnamemodify(M.options.path, ":p:h"), "p")

  if M.options.max_size then
    -- Simulate opening the log at startup, so that any potential file system
    -- issues arise sooner than later. Also forces log to be created or pruned.
    local log = M.open_log()
    if log then
      log:close()
    else
      vim.notify("Could not open Fidget log: " .. M.options.path, vim.log.levels.WARN)
    end
  end
end)

function M.fmt_level(level)
  if level == vim.log.levels.DEBUG then
    return "DEBUG"
  elseif level == vim.log.levels.INFO then
    return "INFO"
  elseif level == vim.log.levels.WARN then
    return "WARN"
  elseif level == vim.log.levels.ERROR then
    return "ERROR"
  else
    return "UNKNOWN"
  end
end

local function round(x, increment)
  increment = increment or 1
  x = x / increment
  return (x > 0 and math.floor(x + .5) or math.ceil(x - .5)) * increment
end

local function make_string(...)
  local t = {}
  for i = 1, select("#", ...) do
    local x = select(i, ...)

    if type(x) == "number" and M.options.float_precision then
      x = tostring(round(x, M.options.float_precision))
    elseif type(x) == "table" then
      x = vim.inspect(x)
    else
      x = tostring(x)
    end

    t[#t + 1] = x
  end
  return table.concat(t, " ")
end

local function do_log(level, ...)
  if level < M.options.level then
    return
  end

  -- if M.options.max_size then
  --   M.prune_log(false)
  -- end

  local info = debug.getinfo(3, "Sl")
  local _, _, filename = string.find(info.short_src, PLUGIN_PATH_PATTERN)
  local lineinfo = (filename or info.short_src) .. ":" .. info.currentline

  local log = M.open_log()
  if log then
    local log_line = string.format("[%-6s%s] %s: %s\n",
      M.fmt_level(level), os.date(), lineinfo, make_string(...))
    log:write(log_line)
    log:close()
  end
end

--- Log at the specified level.
function M.log(level, ...)
  do_log(level, ...)
end

--- Log a message at the DEBUG level.
function M.debug(...)
  do_log(vim.log.levels.DEBUG, ...)
end

--- Log a message at the INFO level.
function M.info(...)
  do_log(vim.log.levels.INFO, ...)
end

--- Log a message at the WARN level.
function M.warn(...)
  do_log(vim.log.levels.WARN, ...)
end

--- Log a message at the ERROR level.
function M.error(...)
  do_log(vim.log.levels.ERROR, ...)
end

--- Whether a logging level is enabled.
---
--- Useful for guarding against computing log output that is thrown away.
---
---@param level 0|1|2|3|4|5
---@return boolean at_level
function M.at_level(level)
  return level >= M.options.level
end

--- Open the Fidget log; prune the existing log if it has grown too large.
---
--- Possibly returns an open file handle to the log; it is the caller's
--- responsibility to `:close()` it.
---
---@return file*|nil
function M.open_log()
  if not M.options.enable then
    return
  end

  local fp = io.open(M.options.path, "a")
  if fp == nil then
    return
  end

  local size = fp:seek("end") / 1024
  if M.options.max_size == false or size < M.options.max_size then
    return fp
  end

  fp:close()
  os.rename(M.options.path, M.options.path .. ".bak")
  return io.open(M.options.path, "a")
end

return M

```

## LICENSE

```text
The MIT License (MIT)

Copyright (c) 2022 John Hui

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
