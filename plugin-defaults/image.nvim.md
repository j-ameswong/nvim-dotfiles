# image.nvim defaults and configuration source

Commit: `365e2ace0f619164ae6fd2f6f1d2807775dd6849`

These are the upstream configuration sources at the locked commit. Defaults defined in code are reproduced verbatim; documentation is included for plugins whose settings are not expressed as one Lua table.

## lua/image/init.lua

```lua
local logger = require("image/utils/logger")
local processors = require("image/processors")
local render_scheduler = require("image/utils/render_scheduler")
local report = require("image/report")
local utils = require("image/utils")
local log = logger.within("core")

---@type table<string, string>
local backend_modules = {
  kitty = "image/backends/kitty",
  ueberzug = "image/backends/ueberzug",
  sixel = "image/backends/sixel",
}

---@type Options
local default_options = {
  -- backend = "ueberzug",
  backend = "kitty",
  processor = "magick_cli",
  debug = {
    enabled = false,
    level = "debug",
    file_path = "/tmp/image.nvim.log",
    format = "compact",
  },
  integrations = {
    markdown = {
      enabled = true,
    },
    asciidoc = {
      enabled = true,
    },
    typst = {
      enabled = true,
    },
    neorg = {
      enabled = true,
    },
    syslang = {
      enabled = true,
    },
    html = {
      enabled = false,
    },
    css = {
      enabled = false,
    },
    org = {
      enabled = false,
    },
  },
  max_width = nil,
  max_height = nil,
  max_width_window_percentage = 100,
  max_height_window_percentage = 50,
  scale_factor = 1.0,
  kitty_method = "normal",
  kitty_direct_chunk_size = 4096,
  window_overlap_clear_enabled = false,
  window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif", "scrollview", "scrollview_sign" },
  editor_only_render_when_focused = false,
  tmux_show_only_in_active_window = false,
  ignore_download_error = false,
  hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
}

---@type State
local state = {
  ---@diagnostic disable-next-line: assign-type-mismatch
  backend = nil,
  ---@diagnostic disable-next-line: assign-type-mismatch
  processor = nil,
  options = default_options,
  images = {},
  extmarks_namespace = vim.api.nvim_create_namespace("image.nvim"),
  remote_cache = {},
  tmp_dir = vim.fn.tempname(),
  disable_decorator_handling = false,
  hijacked_win_buf_images = {},
  enabled = true,
}

---@type API
---@diagnostic disable-next-line: missing-fields
local api = {}

---@param name string
local function validate_backend(name)
  if not backend_modules[name] then utils.throw("image.nvim: backend not found: " .. tostring(name)) end
end

---@param name string
---@return Backend
local function create_lazy_backend(name)
  validate_backend(name)
  local backend = nil
  local load_backend = function()
    if backend then return backend end
    backend = require(backend_modules[name])
    if type(backend.setup) == "function" then backend.setup(state) end
    return backend
  end
  return setmetatable({}, {
    __index = function(_, key)
      return load_backend()[key]
    end,
    __newindex = function(_, key, value)
      load_backend()[key] = value
    end,
  })
end

---@param options Options
api.setup = function(options)
  local opts = vim.tbl_deep_extend("force", default_options, options or {})
  state.options = opts

  -- setup logger with debug configuration
  if opts.debug then logger.setup(opts.debug) end

  if opts.processor == "magick_rock" then
    vim.schedule(function()
      require("image/magick").warn_if_magick_rock_missing()
    end)
  end

  state.processor = processors.create_lazy_processor(opts.processor)
  state.backend = create_lazy_backend(opts.backend)
  render_scheduler.clear()

  -- load integrations
  for integration_name, integration_options in pairs(opts.integrations) do
    if integration_options.enabled then
      log.debug("Loading integration: " .. integration_name)
      local ok, integration = pcall(require, "image/integrations/" .. integration_name)
      if not ok then
        log.error("Failed to load integration: " .. integration_name, integration)
      elseif type(integration.setup) == "function" then
        integration.setup(api, integration_options, state)
        log.debug("Setup integration: " .. integration_name)
      end
    end
  end

  -- create tmp dir
  vim.fn.mkdir(state.tmp_dir, "p")

  local render_window_images = function(winid)
    if not state.enabled then return end
    if not winid or not vim.api.nvim_win_is_valid(winid) then return end

    local bufnr = vim.api.nvim_win_get_buf(winid)
    for _, current_image in ipairs(api.get_images({ window = winid, buffer = bufnr })) do
      current_image:render()
    end
  end

  local schedule_window_render = function(winid)
    if not winid then return end
    render_scheduler.schedule(("core:window:%d"):format(winid), function()
      render_window_images(winid)
    end)
  end

  local schedule_all_window_render = function()
    render_scheduler.schedule("core:all-windows", function()
      if not state.enabled then return end

      local windows_to_render = {}
      for _, current_image in ipairs(api.get_images()) do
        if current_image.window ~= nil then
          state.backend.clear(current_image.id, true)
          windows_to_render[current_image.window] = true
        end
      end
      for winid in pairs(windows_to_render) do
        render_window_images(winid)
      end
    end)
  end

  -- handle folds / scroll extra
  ---@type table<number, { topline: number, botline: number, bufnr: number, height: number; folded_lines: number }>
  local window_history = {}
  vim.api.nvim_set_decoration_provider(state.extmarks_namespace, {
    on_win = function(_, winid, bufnr, topline, botline)
      -- bail if not enabled
      if not state.enabled then return false end

      -- bail if decorator handling is disabled
      if state.disable_decorator_handling then return false end

      -- bail if not in normal mode, there's a weird behavior where in visual mode this callback gets called CONTINUOUSLY
      if vim.api.nvim_get_mode().mode ~= "n" then return false end

      if not vim.api.nvim_win_is_valid(winid) then return false end
      if not vim.api.nvim_buf_is_valid(bufnr) then return false end

      local prev = window_history[winid]
      local buffer_changed = prev ~= nil and prev.bufnr ~= bufnr
      if buffer_changed then
        for _, curr in ipairs(api.get_images({ window = winid, buffer = prev.bufnr })) do
          curr:clear(true)
        end
      end

      -- bail if there are no images
      local all_images = api.get_images()
      if #all_images == 0 then
        window_history[winid] = { topline = topline, botline = botline, bufnr = bufnr }
        return false
      end

      -- toggle images in overlapped windows
      if state.options.window_overlap_clear_enabled then
        render_scheduler.schedule("core:overlap", function()
          local windows = utils.window.get_windows({
            normal = true,
            floating = true,
            with_masks = true,
            ignore_masking_filetypes = state.options.window_overlap_clear_ft_ignore,
          })

          for _, current_window in ipairs(windows) do
            local cur_win_images = api.get_images({ window = current_window.id, buffer = current_window.buffer })
            if #current_window.masks > 0 then
              for _, current_image in ipairs(cur_win_images) do
                current_image:clear(true)
              end
            else
              for _, current_image in ipairs(cur_win_images) do
                if not current_image.is_rendered then current_image:render() end
              end
            end
          end
        end)
      end

      -- bail if there are no images tied to this window and buffer pair
      local images = api.get_images({ window = winid, buffer = bufnr })
      if #images == 0 then
        window_history[winid] = { topline = topline, botline = botline, bufnr = bufnr }
        return false
      end

      -- get current window
      local window = utils.window.get_window(winid)
      if not window then return false end

      if not prev then
        window_history[winid] = { topline = topline, botline = botline, bufnr = bufnr }
        return false
      end

      local height = vim.api.nvim_win_get_height(winid)
      local needs_rerender = buffer_changed

      -- rerender if height, topline, or botline changed
      needs_rerender = needs_rerender or prev.topline ~= topline or prev.botline ~= botline or prev.height ~= height

      -- rerender if the amount of folded lines changed
      local folded_lines = 0
      local i = 1
      while i < botline do
        local fold_start, fold_end = vim.fn.foldclosed(i), vim.fn.foldclosedend(i)
        if fold_start ~= -1 and fold_end ~= -1 then
          folded_lines = folded_lines + (fold_end - fold_start)
          i = fold_end + 1
        else
          i = i + 1
        end
      end
      if prev.folded_lines ~= folded_lines then needs_rerender = true end

      -- store new state
      window_history[winid] =
        { topline = topline, botline = botline, bufnr = bufnr, height = height, folded_lines = folded_lines }

      -- execute deferred clear / rerender
      log.debug("needs_rerender", { needs_rerender = needs_rerender })
      render_scheduler.schedule(("core:decorator:%d"):format(winid), function()
        if not needs_rerender then return end
        if not vim.api.nvim_win_is_valid(winid) then return end
        if vim.api.nvim_win_get_buf(winid) ~= bufnr then return end
        render_window_images(winid)
      end)

      return false
    end,
  })

  -- setup autocommands
  local group = vim.api.nvim_create_augroup("image.nvim", { clear = true })

  -- auto-clear on buffer / window close
  vim.api.nvim_create_autocmd({ "BufLeave", "WinClosed", "TabEnter" }, {
    group = group,
    callback = function() -- auto-clear images when windows and buffers change
      -- bail if not enabled
      if not state.enabled then return end

      vim.schedule(function()
        local images = api.get_images()

        local windows_in_current_tab = vim.api.nvim_tabpage_list_wins(0)
        local windows_in_current_tab_map = {}
        for _, current_window in ipairs(windows_in_current_tab) do
          windows_in_current_tab_map[current_window] = true
        end

        for _, current_image in ipairs(images) do
          if current_image.window then
            local window_ok, is_valid_window = pcall(vim.api.nvim_win_is_valid, current_image.window)
            if not window_ok or not is_valid_window then
              current_image:clear()
              return
            end

            local is_window_in_current_tab = windows_in_current_tab_map[current_image.window]
            if not is_window_in_current_tab then
              current_image:clear()
              return
            end

            if current_image.buffer then
              local buf_ok, is_valid_buffer = pcall(vim.api.nvim_buf_is_valid, current_image.buffer)
              if not buf_ok or not is_valid_buffer then
                current_image:clear()
                return
              end

              local is_buffer_in_window = vim.api.nvim_win_get_buf(current_image.window) == current_image.buffer
              if not is_buffer_in_window then current_image:clear() end
            end
          end
        end
      end)
    end,
  })

  -- rerender on scroll
  vim.api.nvim_create_autocmd({ "WinScrolled" }, {
    group = group,
    callback = function(au)
      if not state.enabled then return end
      schedule_window_render(tonumber(au.file))
    end,
  })

  -- force rerender on resize (handles VimResized as well)
  vim.api.nvim_create_autocmd({ "WinResized", "WinNew" }, {
    group = group,
    callback = function()
      if not state.enabled then return end
      schedule_all_window_render()
    end,
  })

  -- auto-clear on VimSuspend and re-render on VimResume
  local image_to_restore_on_resume = {}
  vim.api.nvim_create_autocmd({ "VimSuspend" }, {
    group = group,
    callback = function()
      local images = api.get_images()
      for _, current_image in ipairs(images) do
        current_image:clear()
      end
      image_to_restore_on_resume = images
    end,
  })
  vim.api.nvim_create_autocmd({ "VimResume" }, {
    group = group,
    callback = function()
      local images = image_to_restore_on_resume
      for _, current_image in ipairs(images) do
        current_image:render()
      end
    end,
  })

  -- auto-toggle on editor focus change
  if
    state.options.editor_only_render_when_focused
    or (state.options.tmux_show_only_in_active_window and utils.tmux.is_tmux)
  then
    local images_to_restore_on_focus = {}
    local initial_tmux_window_id = utils.tmux.get_window_id()
    local initial_tmux_session = utils.tmux.get_current_session()

    vim.api.nvim_create_autocmd("FocusLost", {
      group = group,
      callback = function() -- auto-clear images when windows and buffers change
        -- bail if not enabled
        if not state.enabled then return end

        vim.schedule(function()
          log.debug("FocusLost")
          if
            state.options.editor_only_render_when_focused
            or (utils.tmux.is_tmux and utils.tmux.get_window_id() ~= initial_tmux_window_id)
            or (utils.tmux.is_tmux and utils.tmux.get_current_session() ~= initial_tmux_session)
          then
            state.disable_decorator_handling = true

            local images = api.get_images()
            for _, current_image in ipairs(images) do
              if current_image.is_rendered then
                current_image:clear(true)
                table.insert(images_to_restore_on_focus, current_image)
              end
            end
          end
        end)
      end,
    })

    vim.api.nvim_create_autocmd("FocusGained", {
      group = group,
      callback = function() -- auto-clear images when windows and buffers change
        -- bail if not enabled
        if not state.enabled then return end

        log.debug("FocusGained")

        state.disable_decorator_handling = false

        vim.schedule_wrap(function()
          -- force rerender
          local images = api.get_images()
          for _, current_image in ipairs(images) do
            if current_image.is_rendered then
              current_image:clear()
              current_image:render()
            end
          end

          -- render images cleared on focus loss
          for _, current_image in ipairs(images_to_restore_on_focus) do
            current_image:render()
          end
          images_to_restore_on_focus = {}
        end)()
      end,
    })
  end

  -- hijack image filetypes
  if state.options.hijack_file_patterns and #state.options.hijack_file_patterns > 0 then
    vim.api.nvim_create_autocmd({
      "WinNew",
      "BufWinEnter",
      "TabEnter",
    }, {
      group = group,
      pattern = state.options.hijack_file_patterns,
      callback = function(event)
        -- bail if not enabled
        if not state.enabled then return end

        local buf = event.buf
        local win = vim.api.nvim_get_current_win()
        local path = vim.api.nvim_buf_get_name(buf)

        api.hijack_buffer(path, win, buf)
      end,
    })
  end

  -- sync with extmarks
  vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged", "TextChangedI", "InsertEnter" }, {
    group = group,
    callback = function(event)
      -- bail if not enabled
      if not state.enabled then return end

      local images = api.get_images({ buffer = event.buf })
      for _, img in ipairs(images) do
        local has_moved, extmark_y, extmark_x = img:has_extmark_moved()
        if has_moved and extmark_x and extmark_y then
          img.geometry.y = extmark_y
          img.geometry.x = extmark_x
          img.extmark.col = extmark_x
          img.extmark.row = extmark_y
          img:render()
        end
      end
    end,
  })

  -- add :ImageReport
  vim.api.nvim_create_user_command("ImageReport", function()
    api.create_report()
  end, {})
end

local guard_setup = function()
  if not state.backend then utils.throw("image.nvim is not setup. Call setup() first.") end
end

---@param path string
---@param win number? if nil or 0, uses current window
---@param buf number? if nil or 0, uses current buffer
---@param options ImageOptions?
---@return Image|nil
api.hijack_buffer = function(path, win, buf, options)
  if not win or win == 0 then win = vim.api.nvim_get_current_win() end
  if not buf or buf == 0 then buf = vim.api.nvim_get_current_buf() end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "" })

  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nowrite"
  vim.bo[buf].filetype = "image_nvim"
  vim.opt_local.colorcolumn = "0"
  vim.opt_local.cursorline = false
  vim.opt_local.number = false
  vim.opt_local.signcolumn = "no"

  local key = ("%s:%s"):format(win, buf)
  if state.hijacked_win_buf_images[key] then
    state.hijacked_win_buf_images[key]:render()
    return state.hijacked_win_buf_images[key]
  end

  local opts = options or {}
  opts.window = win
  opts.buffer = buf
  if not opts.x then opts.x = 0 end
  if not opts.y then opts.y = 0 end

  local img = api.from_file(path, opts)

  if img then
    -- wait for vimenter
    if vim.v.vim_did_enter == 1 then
      img:render()
    else
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          img:render()
        end,
      })
    end
    state.hijacked_win_buf_images[key] = img
  end

  return img
end

---@param path string
---@param options? ImageOptions
api.from_file = function(path, options)
  guard_setup()
  local image = require("image/image")
  return image.from_file(path, options, state)
end

---@param url string
---@param options? ImageOptions
---@param callback fun(image: Image|nil)
api.from_url = function(url, options, callback)
  guard_setup()
  local image = require("image/image")
  image.from_url(url, options, callback, state)
end

---@param id? string
api.clear = function(id)
  guard_setup()
  local target = state.images[id]
  if target then
    target:clear()
  else
    state.backend.clear(id)
  end
end

---@param opts? { window?: number, buffer?: number, namespace?: string }
---@return Image[]
api.get_images = function(opts)
  local images = {}
  local namespace = opts and opts.namespace or nil
  for _, current_image in pairs(state.images) do
    if (namespace and current_image.namespace == namespace) or not namespace then
      if
        (opts and opts.window and opts.window == current_image.window and not opts.buffer)
        or (opts and opts.buffer and opts.buffer == current_image.buffer and not opts.window)
        or (opts and opts.window and opts.buffer and opts.window == current_image.window and opts.buffer == current_image.buffer)
        or not opts
      then
        table.insert(images, current_image)
      end
    end
  end
  return images
end

api.create_report = function()
  guard_setup()
  return report.create(state)
end

---@return boolean
api.is_enabled = function()
  return state.enabled
end

api.enable = function()
  state.enabled = true
  local images = api.get_images()
  for _, current_image in ipairs(images) do
    current_image:render()
  end
end

api.disable = function()
  state.enabled = false
  local images = api.get_images()
  for _, current_image in ipairs(images) do
    current_image:clear(true)
  end
end

return api

```

## lua/image/integrations/asciidoc.lua

```lua
local document = require("image/utils/document")

local function create_fake_ts_node(text, start_row, start_col, end_row, end_col)
  local node = {}
  node._text = text
  node._range = { start_row, start_col, end_row, end_col }

  function node:range()
    return table.unpack(self._range)
  end

  function node:text()
    return self._text
  end

  return node
end

return document.create_document_integration({
  name = "asciidoc",
  debug = true,
  default_options = {
    clear_in_insert_mode = false,
    download_remote_images = true,
    only_render_image_at_cursor = false,
    only_render_image_at_cursor_mode = "popup",
    floating_windows = false,
    filetypes = { "asciidoc", "adoc" },
  },

  query_buffer_images = function(buffer)
    local buf = buffer or vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local images = {}

    local pattern = "image::?([^%[]+)%[(.-)%]"

    for row, line in ipairs(lines) do
      for url, alt in line:gmatch(pattern) do
        local s, e = line:find("image:" .. url .. "[" .. alt .. "]", 1, true)
        if not s then
          s, e = line:find("image::" .. url .. "[" .. alt .. "]", 1, true)
        end
        if s and e then
          local node = create_fake_ts_node(line:sub(s, e), row - 1, s - 1, row - 1, e - 1)
          table.insert(images, {
            node = node,
            url = url,
            alt = alt,
            range = { start_row = row - 1, start_col = s - 1, end_row = row - 1, end_col = e - 1 },
          })
        end
      end
    end

    return images
  end,
})

```

## lua/image/integrations/css.lua

```lua
local document = require("image/utils/document")
return document.create_document_integration({
  name = "css",
  -- debug = true,
  default_options = {
    clear_in_insert_mode = false,
    download_remote_images = true,
    only_render_image_at_cursor = false,
    only_render_image_at_cursor_mode = "popup",
    floating_windows = false,
    filetypes = { "css", "sass", "scss" },
  },
  query_buffer_images = function(buffer)
    local buf = buffer or vim.api.nvim_get_current_buf()

    local parser = vim.treesitter.get_parser(buf, "css")
    local root = parser:parse()[1]:root()
    local query = vim.treesitter.query.parse("css", '(call_expression (function_name) @name (#eq? @name "url"))')

    local images = {}

    ---@diagnostic disable-next-line: missing-parameter
    for id, node in query:iter_captures(root, buf) do
      local capture = query.captures[id]

      if capture == "name" then
        ---@diagnostic disable-next-line: unused-local
        local start_row, start_col, end_row, end_col = node:range()
        local line = vim.api.nvim_buf_get_lines(buf, end_row, end_row + 1, false)[1]

        local path = line:sub(start_col):gsub(".*url%([\"'](.-)[\"']%).*$", "%1")

        -- search for path relative to webroot
        if path:sub(1, 1) == "/" then
          path = vim.fs.find(path:sub(2), {
            upward = true,
            path = vim.fs.dirname(vim.api.nvim_buf_get_name(buf)),
          })[1]
        end

        if path ~= nil then
          table.insert(images, {
            node = node,
            range = {
              start_row = start_row,
              start_col = start_col,
              end_row = end_row,
              end_col = end_col,
            },
            url = path,
          })
        end
      end
    end

    return images
  end,
})

```

## lua/image/integrations/html.lua

```lua
local document = require("image/utils/document")
return document.create_document_integration({
  name = "html",
  -- debug = true,
  default_options = {
    clear_in_insert_mode = false,
    download_remote_images = true,
    only_render_image_at_cursor = false,
    only_render_image_at_cursor_mode = "popup",
    floating_windows = false,
    filetypes = { "html", "xhtml", "htm" },
  },
  query_buffer_images = function(buffer)
    local buf = buffer or vim.api.nvim_get_current_buf()

    local parser = vim.treesitter.get_parser(buf, "html")
    local root = parser:parse()[1]:root()
    local query = vim.treesitter.query.parse(
      "html",
      '(attribute (attribute_name) @name (#eq? @name "src")' .. " (quoted_attribute_value))"
    )

    local images = {}

    ---@diagnostic disable-next-line: missing-parameter
    for id, node in query:iter_captures(root, buf) do
      local capture = query.captures[id]

      if capture == "name" then
        ---@diagnostic disable-next-line: unused-local
        local start_row, start_col, end_row, end_col = node:range()
        local line = vim.api.nvim_buf_get_lines(buf, end_row, end_row + 1, false)[1]

        local path = line:sub(start_col):gsub(".*src=[\"'](.-)[\"'].*$", "%1")

        -- search for path relative to webroot
        if path:sub(1, 1) == "/" then
          path = vim.fs.find(path:sub(2), {
            upward = true,
            path = vim.fs.dirname(vim.api.nvim_buf_get_name(buf)),
          })[1]
        end

        if path ~= nil then
          table.insert(images, {
            node = node,
            range = {
              start_row = start_row,
              start_col = start_col,
              end_row = end_row,
              end_col = end_col,
            },
            url = path,
          })
        end
      end
    end

    return images
  end,
})

```

## lua/image/integrations/markdown.lua

```lua
local document = require("image/utils/document")

return document.create_document_integration({
  name = "markdown",
  debug = true,
  default_options = {
    clear_in_insert_mode = false,
    download_remote_images = true,
    only_render_image_at_cursor = false,
    only_render_image_at_cursor_mode = "popup",
    floating_windows = false,
    filetypes = { "markdown", "vimwiki" },
  },
  query_buffer_images = function(buffer)
    local buf = buffer or vim.api.nvim_get_current_buf()
    local parser = vim.treesitter.get_parser(buf, "markdown")
    parser:parse(true)
    local inline_lang = "markdown_inline"
    local inlines = parser:children()[inline_lang]
    local inline_query = vim.treesitter.query.parse(inline_lang, "(image (link_destination) @url) @image")
    local shortcut_query =
      vim.treesitter.query.parse(inline_lang, "(image (image_description (shortcut_link (link_text) @url))) @image")

    if not inlines then return {} end

    local images = {}
    local function get_inline_images(tree)
      local root = tree:root()
      local current_image = nil

      for _, query in ipairs({ inline_query, shortcut_query }) do
        ---@diagnostic disable-next-line: missing-parameter
        for id, node in query:iter_captures(root, buf) do
          local key = query.captures[id]
          local value = vim.treesitter.get_node_text(node, buf)

          -- TODO: fix node:range() taking into account the extmarks for SOME FKING REASON
          if key == "image" then
            local start_row, start_col, end_row, end_col = node:range()

            current_image = {
              node = node,
              range = {
                start_row = start_row,
                start_col = start_col,
                end_row = end_row,
                end_col = end_col,
              },
            }
          elseif current_image and key == "url" then
            current_image.url = value
            table.insert(images, current_image)
            current_image = nil
          end
        end
      end
    end

    inlines:for_each_tree(get_inline_images)

    return images
  end,
})

```

## lua/image/integrations/neorg.lua

```lua
local document = require("image/utils/document")
local has_neorg = nil

---Resolve workspace notation `$<workspace>/` with neorg if possible
---@param path string
local function maybe_parse_workspace_path(path)
  if has_neorg ~= false and vim.startswith(path, "$") then
    local ok, neorg = pcall(require, "neorg.core")
    has_neorg = ok
    if has_neorg then
      local expanded_path = neorg.modules.get_module("core.dirman.utils").expand_path(path, true)
      if expanded_path ~= nil then
        return true, expanded_path -- successfully resolved workspace
      end
    end
  end
  return false, ""
end

return document.create_document_integration({
  name = "neorg",
  default_options = {
    clear_in_insert_mode = false,
    download_remote_images = true,
    only_render_image_at_cursor = false,
    only_render_image_at_cursor_mode = "popup",
    floating_windows = false,
    filetypes = { "norg" },
  },
  query_buffer_images = function(buffer)
    local buf = buffer or vim.api.nvim_get_current_buf()

    local parser = vim.treesitter.get_parser(buf, "norg")
    local root = parser:parse()[1]:root()
    local query = vim.treesitter.query.parse("norg", '(infirm_tag (tag_name) @name (#eq? name "image"))')

    local images = {}

    ---@diagnostic disable-next-line: missing-parameter
    for id, node in query:iter_captures(root, buf) do
      local capture = query.captures[id]

      -- assume that everything after the tag + one space is the path/url and trim it
      if capture == "name" then
        local start_row, start_col, end_row, end_col = node:range()
        local line = vim.api.nvim_buf_get_lines(buf, end_row, end_row + 1, false)[1]
        local path = line:sub(end_col + 1):gsub("^%s*(.-)%s*$", "%1")

        table.insert(images, {
          node = node,
          range = { start_row = start_row, start_col = start_col, end_row = end_row, end_col = end_col },
          url = path,
        })

        local ok, workspace_path = maybe_parse_workspace_path(path)
        if ok and workspace_path ~= path then
          table.insert(images, {
            node = node,
            range = { start_row = start_row, start_col = start_col, end_row = end_row, end_col = end_col },
            url = workspace_path,
          })
        end
      end
    end

    return images
  end,
})

```

## lua/image/integrations/org.lua

```lua
local document = require("image/utils/document")
local magic = require("image/utils/magic")

return document.create_document_integration({
  name = "org",
  default_options = {
    clear_in_insert_mode = false,
    download_remote_images = true,
    only_render_image_at_cursor = false,
    only_render_image_at_cursor_mode = "popup",
    floating_windows = false,
    filetypes = { "org" },
  },
  query_buffer_images = function(buffer)
    local bufnr = buffer or vim.api.nvim_get_current_buf()

    local parser = vim.treesitter.get_parser(bufnr, "org")
    local root = parser:parse()[1]:root()

    local images = {}
    local query = vim.treesitter.query.parse(
      "org",
      [[
      (link_desc url: (expr) @image_link)
      (link url: (expr) @image_link)
    ]]
    )

    for _, node in query:iter_captures(root, bufnr) do
      local text = vim.treesitter.get_node_text(node, bufnr)
      if text then
        local relpath = vim.fn.expand(text:gsub("^file:", ""))
        local srcfile_abspath = vim.api.nvim_buf_get_name(bufnr)
        local base_dir = vim.fn.fnamemodify(srcfile_abspath, ":h")
        local abspath = vim.fn.fnamemodify(base_dir .. "/" .. relpath, ":p")
        if magic.is_image(abspath) then
          local start_row, start_col, end_row, end_col = node:range()
          table.insert(images, {
            node = node,
            range = {
              start_row = start_row,
              start_col = start_col,
              end_row = end_row,
              end_col = end_col,
            },
            url = abspath,
          })
        end
      end
    end

    return images
  end,
})

```

## lua/image/integrations/rst.lua

```lua
local document = require("image/utils/document")

return document.create_document_integration({
  name = "rst",
  debug = true,
  default_options = {
    clear_in_insert_mode = true,
    download_remote_images = true,
    only_render_image_at_cursor = false,
    only_render_image_at_cursor_mode = "popup",
    floating_windows = false,
    filetypes = { "rst" },
  },
  query_buffer_images = function(buffer)
    local buf = buffer or vim.api.nvim_get_current_buf()
    local parser = vim.treesitter.get_parser(buf, "rst")
    parser:parse(true)

    local image_directive_query = vim.treesitter.query.parse(
      "rst",
      [[
      ((directive
          name: (type) @_type
          body: (body (arguments) @url)) @image
       (#any-of? @_type "image" "figure"))
    ]]
    )

    local images = {}

    local function get_images(tree)
      local root = tree:root()
      local current_image = nil

      for id, node in image_directive_query:iter_captures(root, buf) do
        local key = image_directive_query.captures[id]
        local value = vim.treesitter.get_node_text(node, buf)

        if key == "image" then
          local start_row, start_col, end_row, end_col = node:range()

          current_image = {
            node = node,
            range = {
              start_row = start_row,
              start_col = start_col,
              end_row = end_row,
              end_col = end_col,
            },
          }
        elseif current_image and key == "url" then
          current_image.url = value
          table.insert(images, current_image)
          current_image = nil
        end
      end
    end

    parser:for_each_tree(get_images)

    return images
  end,
})

```

## lua/image/integrations/syslang.lua

```lua
local document = require("image/utils/document")

return document.create_document_integration({
  name = "syslang",
  -- debug = true,
  default_options = {
    clear_in_insert_mode = false,
    download_remote_images = true,
    only_render_image_at_cursor = false,
    only_render_image_at_cursor_mode = "popup",
    floating_windows = false,
    filetypes = { "syslang" },
  },
  query_buffer_images = function(buffer)
    local buf = buffer or vim.api.nvim_get_current_buf()

    local parser = vim.treesitter.get_parser(buf, "syslang")
    local root = parser:parse()[1]:root()
    local query = vim.treesitter.query.parse("syslang", "(image (image_url) @url) @image")

    local images = {}
    local current_image = nil

    ---@diagnostic disable-next-line: missing-parameter
    for id, node in query:iter_captures(root, buf) do
      local key = query.captures[id]
      local value = vim.treesitter.get_node_text(node, buf)

      if key == "image" then
        local start_row, start_col, end_row, end_col = node:range()
        current_image = {
          node = node,
          range = { start_row = start_row, start_col = start_col, end_row = end_row, end_col = end_col },
        }
      elseif current_image and key == "url" then
        current_image.url = value
        table.insert(images, current_image)
        current_image = nil
      end
    end

    return images
  end,
})

```

## lua/image/integrations/typst.lua

```lua
local document = require("image/utils/document")
return document.create_document_integration({
  name = "typst",
  -- debug = true,
  default_options = {
    clear_in_insert_mode = false,
    download_remote_images = true,
    only_render_image_at_cursor = false,
    only_render_image_at_cursor_mode = "popup",
    floating_windows = false,
    filetypes = { "typst" },
  },
  query_buffer_images = function(buffer)
    local buf = buffer or vim.api.nvim_get_current_buf()

    local parser = vim.treesitter.get_parser(buf, "typst")
    local root = parser:parse()[1]:root()
    local query =
      vim.treesitter.query.parse("typst", '(call item: (ident) @name (#eq? @name "image") (group (string) @url))')

    local images = {}
    local current_image = nil

    ---@diagnostic disable-next-line: missing-parameter
    for id, node in query:iter_captures(root, buf) do
      local capture = query.captures[id]
      local value = vim.treesitter.get_node_text(node, buf)

      if capture == "name" then
        -- Get the parent since we want the "call" and not only the "ident"
        local start_row, start_col, end_row, end_col = node:parent():range()
        current_image = {
          node = node,
          range = { start_row = start_row, start_col = start_col, end_row = end_row, end_col = end_col },
        }
      elseif current_image and capture == "url" then
        -- We need to remove the quotes from the string
        -- '"The URL"' -> "The URL"
        current_image.url = string.sub(value, 2, -2)

        table.insert(images, current_image)
        current_image = nil
      end
    end

    return images
  end,
})

```

## LICENSE

```text
Copyright 2023 Andrei Neculaesei

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


```
