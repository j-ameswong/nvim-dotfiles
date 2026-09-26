# blink.cmp defaults and configuration source

Commit: `78336bc89ee5365633bcf754d93df01678b5c08f`

These are the upstream configuration sources at the locked commit. Defaults defined in code are reproduced verbatim; documentation is included for plugins whose settings are not expressed as one Lua table.

## lua/blink/cmp/config/appearance.lua

```lua
--- @class (exact) blink.cmp.AppearanceConfig
--- @field highlight_ns number
--- @field use_nvim_cmp_as_default boolean Sets the fallback highlight groups to nvim-cmp's highlight groups. Useful for when your theme doesn't support blink.cmp, will be removed in a future release.
--- @field nerd_font_variant 'mono' | 'normal' Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'. Adjusts spacing to ensure icons are aligned
--- @field kind_icons table<string, string>

local validate = require('blink.cmp.config.utils').validate
local appearance = {
  --- @type blink.cmp.AppearanceConfig
  default = {
    highlight_ns = vim.api.nvim_create_namespace('blink_cmp'),
    use_nvim_cmp_as_default = false,
    nerd_font_variant = 'mono',
    kind_icons = {
      Text = '󰉿',
      Method = '󰊕',
      Function = '󰊕',
      Constructor = '󰒓',

      Field = '󰜢',
      Variable = '󰆦',
      Property = '󰖷',

      Class = '󱡠',
      Interface = '󱡠',
      Struct = '󱡠',
      Module = '󰅩',

      Unit = '󰪚',
      Value = '󰦨',
      Enum = '󰦨',
      EnumMember = '󰦨',

      Keyword = '󰻾',
      Constant = '󰏿',

      Snippet = '󱄽',
      Color = '󰏘',
      File = '󰈔',
      Reference = '󰬲',
      Folder = '󰉋',
      Event = '󱐋',
      Operator = '󰪚',
      TypeParameter = '󰬛',
    },
  },
}

function appearance.validate(config)
  validate('appearance', {
    highlight_ns = { config.highlight_ns, 'number' },
    use_nvim_cmp_as_default = { config.use_nvim_cmp_as_default, 'boolean' },
    nerd_font_variant = { config.nerd_font_variant, 'string' },
    kind_icons = { config.kind_icons, 'table' },
  }, config)
end

return appearance

```

## lua/blink/cmp/config/completion/accept.lua

```lua
--- @class (exact) blink.cmp.CompletionAcceptConfig
--- @field dot_repeat boolean Write completions to the `.` register
--- @field create_undo_point boolean Create an undo point when accepting a completion item
--- @field resolve_timeout_ms number How long to wait for the LSP to resolve the item with additional information before continuing as-is
--- @field auto_brackets blink.cmp.AutoBracketsConfig

--- @class (exact) blink.cmp.AutoBracketsConfig
--- @field enabled boolean Whether to auto-insert brackets for functions
--- @field default_brackets string[] Default brackets to use for unknown languages
--- @field override_brackets_for_filetypes table<string, string[] | fun(item: blink.cmp.CompletionItem): string[]>
--- @field force_allow_filetypes string[] Overrides the default blocked filetypes
--- @field blocked_filetypes string[]
--- @field kind_resolution blink.cmp.AutoBracketResolutionConfig Synchronously use the kind of the item to determine if brackets should be added
--- @field semantic_token_resolution blink.cmp.AutoBracketSemanticTokenResolutionConfig Asynchronously use semantic token to determine if brackets should be added

--- @class (exact) blink.cmp.AutoBracketResolutionConfig
--- @field enabled boolean
--- @field blocked_filetypes string[]

--- @class (exact) blink.cmp.AutoBracketSemanticTokenResolutionConfig
--- @field enabled boolean
--- @field blocked_filetypes string[]
--- @field timeout_ms number How long to wait for semantic tokens to return before assuming no brackets should be added

local validate = require('blink.cmp.config.utils').validate
local accept = {
  --- @type blink.cmp.CompletionAcceptConfig
  default = {
    dot_repeat = true,
    create_undo_point = true,
    resolve_timeout_ms = 100,
    auto_brackets = {
      enabled = true,
      default_brackets = { '(', ')' },
      override_brackets_for_filetypes = {},
      force_allow_filetypes = {},
      blocked_filetypes = {},
      kind_resolution = {
        enabled = true,
        blocked_filetypes = { 'typescriptreact', 'javascriptreact', 'vue' },
      },
      semantic_token_resolution = {
        enabled = true,
        blocked_filetypes = { 'java' },
        timeout_ms = 400,
      },
    },
  },
}

function accept.validate(config)
  validate('completion.accept', {
    dot_repeat = { config.dot_repeat, 'boolean' },
    create_undo_point = { config.create_undo_point, 'boolean' },
    resolve_timeout_ms = { config.resolve_timeout_ms, 'number' },
    auto_brackets = { config.auto_brackets, 'table' },
  }, config)
  validate('completion.accept.auto_brackets', {
    enabled = { config.auto_brackets.enabled, 'boolean' },
    default_brackets = { config.auto_brackets.default_brackets, 'table' },
    override_brackets_for_filetypes = { config.auto_brackets.override_brackets_for_filetypes, 'table' },
    force_allow_filetypes = { config.auto_brackets.force_allow_filetypes, 'table' },
    blocked_filetypes = { config.auto_brackets.blocked_filetypes, 'table' },
    kind_resolution = { config.auto_brackets.kind_resolution, 'table' },
    semantic_token_resolution = { config.auto_brackets.semantic_token_resolution, 'table' },
  }, config.auto_brackets)
  validate('completion.accept.auto_brackets.kind_resolution', {
    enabled = { config.auto_brackets.kind_resolution.enabled, 'boolean' },
    blocked_filetypes = { config.auto_brackets.kind_resolution.blocked_filetypes, 'table' },
  }, config.auto_brackets.kind_resolution)
  validate('completion.accept.auto_brackets.semantic_token_resolution', {
    enabled = { config.auto_brackets.semantic_token_resolution.enabled, 'boolean' },
    blocked_filetypes = { config.auto_brackets.semantic_token_resolution.blocked_filetypes, 'table' },
    timeout_ms = { config.auto_brackets.semantic_token_resolution.timeout_ms, 'number' },
  }, config.auto_brackets.semantic_token_resolution)
end

return accept

```

## lua/blink/cmp/config/completion/documentation.lua

```lua
--- @class (exact) blink.cmp.CompletionDocumentationConfig
--- @field auto_show boolean Controls whether the documentation window will automatically show when selecting a completion item
--- @field auto_show_delay_ms number Delay before showing the documentation window
--- @field update_delay_ms number Delay before updating the documentation window when selecting a new item, while an existing item is still visible
--- @field treesitter_highlighting boolean Whether to use treesitter highlighting, disable if you run into performance issues
--- @field draw fun(opts: blink.cmp.CompletionDocumentationDrawOpts): nil Renders the item in the documentation window, by default using an internal treesitter based implementation
--- @field window blink.cmp.CompletionDocumentationWindowConfig

--- @class (exact) blink.cmp.CompletionDocumentationWindowConfig
--- @field min_width number
--- @field max_width number
--- @field max_height number
--- @field desired_min_width number
--- @field desired_min_height number
--- @field border blink.cmp.WindowBorder
--- @field winblend number
--- @field winhighlight string
--- @field scrollbar boolean Note that the gutter will be disabled when border ~= 'none'
--- @field direction_priority blink.cmp.CompletionDocumentationDirectionPriorityConfig Which directions to show the window, for each of the possible menu window directions, falling back to the next direction when there's not enough space

--- @class (exact) blink.cmp.CompletionDocumentationDirectionPriorityConfig
--- @field menu_north ("n" | "s" | "e" | "w")[]
--- @field menu_south ("n" | "s" | "e" | "w")[]

--- @class blink.cmp.CompletionDocumentationDrawOpts
--- @field item blink.cmp.CompletionItem
--- @field window blink.cmp.Window
--- @field config blink.cmp.CompletionDocumentationConfig
--- @field default_implementation fun(opts?: blink.cmp.RenderDetailAndDocumentationOptsPartial)

local validate = require('blink.cmp.config.utils').validate
local documentation = {
  --- @type blink.cmp.CompletionDocumentationConfig
  default = {
    auto_show = false,
    auto_show_delay_ms = 500,
    update_delay_ms = 50,
    treesitter_highlighting = true,
    draw = function(opts) opts.default_implementation() end,
    window = {
      min_width = 10,
      max_width = 80,
      max_height = 20,
      desired_min_width = 50,
      desired_min_height = 10,
      border = nil,
      winblend = 0,
      winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc',
      scrollbar = true,
      direction_priority = {
        menu_north = { 'e', 'w', 'n', 's' },
        menu_south = { 'e', 'w', 's', 'n' },
      },
    },
  },
}

function documentation.validate(config)
  assert(
    config.update_delay_ms >= 50,
    'completion.documentation.update_delay_ms must be >= 50. Setting it lower will cause noticeable lag'
  )

  validate('completion.documentation', {
    auto_show = { config.auto_show, 'boolean' },
    auto_show_delay_ms = { config.auto_show_delay_ms, 'number' },
    update_delay_ms = { config.update_delay_ms, 'number' },
    treesitter_highlighting = { config.treesitter_highlighting, 'boolean' },
    draw = { config.draw, 'function' },
    window = { config.window, 'table' },
  }, config)

  validate('completion.documentation.window', {
    min_width = { config.window.min_width, 'number' },
    max_width = { config.window.max_width, 'number' },
    max_height = { config.window.max_height, 'number' },
    desired_min_width = { config.window.desired_min_width, 'number' },
    desired_min_height = { config.window.desired_min_height, 'number' },
    border = { config.window.border, { 'string', 'table' }, true },
    winblend = { config.window.winblend, 'number' },
    winhighlight = { config.window.winhighlight, 'string' },
    scrollbar = { config.window.scrollbar, 'boolean' },
    direction_priority = { config.window.direction_priority, 'table' },
  }, config.window)

  validate('completion.documentation.window.direction_priority', {
    menu_north = {
      config.window.direction_priority.menu_north,
      function(directions)
        if type(directions) ~= 'table' or #directions == 0 then return false end
        for _, direction in ipairs(directions) do
          if not vim.tbl_contains({ 'n', 's', 'e', 'w' }, direction) then return false end
        end
        return true
      end,
      'one of: "n", "s", "e", "w"',
    },
    menu_south = {
      config.window.direction_priority.menu_south,
      function(directions)
        if type(directions) ~= 'table' or #directions == 0 then return false end
        for _, direction in ipairs(directions) do
          if not vim.tbl_contains({ 'n', 's', 'e', 'w' }, direction) then return false end
        end
        return true
      end,
      'one of: "n", "s", "e", "w"',
    },
  }, config.window.direction_priority)
end

return documentation

```

## lua/blink/cmp/config/completion/ghost_text.lua

```lua
--- Displays a preview of the selected item on the current line
--- @class (exact) blink.cmp.CompletionGhostTextConfig
--- @field enabled boolean | fun(): boolean
--- @field show_with_selection boolean Show the ghost text when an item has been selected
--- @field show_without_selection boolean Show the ghost text when no item has been selected, defaulting to the first item
--- @field show_with_menu boolean Show the ghost text when the menu is open
--- @field show_without_menu boolean Show the ghost text when the menu is closed

local validate = require('blink.cmp.config.utils').validate
local ghost_text = {
  --- @type blink.cmp.CompletionGhostTextConfig
  default = {
    enabled = false,
    show_with_selection = true,
    show_without_selection = false,
    show_with_menu = true,
    show_without_menu = true,
  },
}

function ghost_text.validate(config)
  validate('completion.ghost_text', {
    enabled = { config.enabled, { 'boolean', 'function' } },
    show_with_selection = { config.show_with_selection, 'boolean' },
    show_without_selection = { config.show_without_selection, 'boolean' },
    show_without_menu = { config.show_without_menu, 'boolean' },
    show_with_menu = { config.show_with_menu, 'boolean' },
  }, config)
end

return ghost_text

```

## lua/blink/cmp/config/completion/init.lua

```lua
--- @class (exact) blink.cmp.CompletionConfig
--- @field keyword blink.cmp.CompletionKeywordConfig
--- @field trigger blink.cmp.CompletionTriggerConfig
--- @field list blink.cmp.CompletionListConfig
--- @field accept blink.cmp.CompletionAcceptConfig
--- @field menu blink.cmp.CompletionMenuConfig
--- @field documentation blink.cmp.CompletionDocumentationConfig
--- @field ghost_text blink.cmp.CompletionGhostTextConfig

local validate = require('blink.cmp.config.utils').validate
local completion = {
  default = {
    keyword = require('blink.cmp.config.completion.keyword').default,
    trigger = require('blink.cmp.config.completion.trigger').default,
    list = require('blink.cmp.config.completion.list').default,
    accept = require('blink.cmp.config.completion.accept').default,
    menu = require('blink.cmp.config.completion.menu').default,
    documentation = require('blink.cmp.config.completion.documentation').default,
    ghost_text = require('blink.cmp.config.completion.ghost_text').default,
  },
}

function completion.validate(config)
  validate('completion', {
    keyword = { config.keyword, 'table' },
    trigger = { config.trigger, 'table' },
    list = { config.list, 'table' },
    accept = { config.accept, 'table' },
    menu = { config.menu, 'table' },
    documentation = { config.documentation, 'table' },
    ghost_text = { config.ghost_text, 'table' },
  }, config)
  require('blink.cmp.config.completion.keyword').validate(config.keyword)
  require('blink.cmp.config.completion.trigger').validate(config.trigger)
  require('blink.cmp.config.completion.list').validate(config.list)
  require('blink.cmp.config.completion.accept').validate(config.accept)
  require('blink.cmp.config.completion.menu').validate(config.menu)
  require('blink.cmp.config.completion.documentation').validate(config.documentation)
  require('blink.cmp.config.completion.ghost_text').validate(config.ghost_text)
end

return completion

```

## lua/blink/cmp/config/completion/keyword.lua

```lua
--- @class (exact) blink.cmp.CompletionKeywordConfig
--- 'prefix' will fuzzy match on the text before the cursor
--- 'full' will fuzzy match on the text before *and* after the cursor
--- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
--- @field range blink.cmp.CompletionKeywordRange
---
--- @alias blink.cmp.CompletionKeywordRange
--- | 'prefix' Fuzzy match on the text before the cursor (example: 'foo_|bar' will match 'foo_')
--- | 'full' Fuzzy match on the text before *and* after the cursor (example: 'foo_|_bar' will match 'foo__bar')

local validate = require('blink.cmp.config.utils').validate
local keyword = {
  --- @type blink.cmp.CompletionKeywordConfig
  default = { range = 'prefix' },
}

function keyword.validate(config)
  validate('completion.keyword', {
    range = {
      config.range,
      function(range) return vim.tbl_contains({ 'prefix', 'full' }, range) end,
      'one of: prefix, full',
    },
  }, config)
end

return keyword

```

## lua/blink/cmp/config/completion/list.lua

```lua
--- @class (exact) blink.cmp.CompletionListConfig
--- @field max_items number Maximum number of items to display
--- @field selection blink.cmp.CompletionListSelectionConfig
--- @field cycle blink.cmp.CompletionListCycleConfig

--- @class (exact) blink.cmp.CompletionListSelectionConfig
--- @field preselect boolean | fun(ctx: blink.cmp.Context): boolean When `true`, will automatically select the first item in the completion list
--- @field auto_insert boolean | fun(ctx: blink.cmp.Context): boolean When `true`, inserts the completion item automatically when selecting it. You may want to bind a key to the `cancel` command (default <C-e>) when using this option, which will both undo the selection and hide the completion menu

--- @class (exact) blink.cmp.CompletionListCycleConfig
--- @field from_bottom boolean When `true`, calling `select_next` at the *bottom* of the completion list will select the *first* completion item.
--- @field from_top boolean When `true`, calling `select_prev` at the *top* of the completion list will select the *last* completion item.

local validate = require('blink.cmp.config.utils').validate
local list = {
  --- @type blink.cmp.CompletionListConfig
  default = {
    max_items = 200,
    selection = {
      preselect = true,
      auto_insert = true,
    },
    cycle = {
      from_bottom = true,
      from_top = true,
    },
  },
}

function list.validate(config)
  if type(config.selection) == 'function' then
    error(
      '`completion.list.selection` has been replaced with `completion.list.selection.preselect` and `completion.list.selection.auto_insert`. See the docs for more info: https://cmp.saghen.dev/configuration/completion.html#list'
    )
  end

  validate('completion.list', {
    max_items = { config.max_items, 'number' },
    selection = { config.selection, 'table' },
    cycle = { config.cycle, 'table' },
  }, config)

  validate('completion.list.selection', {
    preselect = { config.selection.preselect, { 'boolean', 'function' } },
    auto_insert = { config.selection.auto_insert, { 'boolean', 'function' } },
  }, config.selection)

  validate('completion.list.cycle', {
    from_bottom = { config.cycle.from_bottom, 'boolean' },
    from_top = { config.cycle.from_top, 'boolean' },
  }, config.cycle)
end

return list

```

## lua/blink/cmp/config/completion/menu.lua

```lua
local validate = require('blink.cmp.config.utils').validate

--- @class (exact) blink.cmp.CompletionMenuConfig
--- @field enabled boolean
--- @field min_width number
--- @field max_height number
--- @field border blink.cmp.WindowBorder
--- @field winblend number
--- @field winhighlight string
--- @field scrolloff number Keep the cursor X lines away from the top/bottom of the window
--- @field scrollbar boolean Note that the gutter will be disabled when border ~= 'none'
--- @field direction_priority ("n" | "s")[]| fun(): ("n" | "s")[] Which directions to show the window, or a function returning such a table, falling back to the next direction when there's not enough space
--- @field order blink.cmp.CompletionMenuOrderConfig TODO: implement
--- @field auto_show boolean | fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): boolean Whether to automatically show the window when new completion items are available
--- @field auto_show_delay_ms number | fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): number Delay before showing the completion menu
--- @field cmdline_position fun(): number[] Screen coordinates (0-indexed) of the command line
--- @field draw blink.cmp.Draw Controls how the completion items are rendered on the popup window

--- @class (exact) blink.cmp.CompletionMenuOrderConfig
--- @field n 'top_down' | 'bottom_up'
--- @field s 'top_down' | 'bottom_up'

local window = {
  --- @type blink.cmp.CompletionMenuConfig
  default = {
    enabled = true,
    min_width = 15,
    max_height = 10,
    border = nil,
    winblend = 0,
    winhighlight = 'Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
    -- keep the cursor X lines away from the top/bottom of the window
    scrolloff = 2,
    -- note that the gutter will be disabled when border ~= 'none'
    scrollbar = true,
    -- which directions to show the window,
    -- falling back to the next direction when there's not enough space
    direction_priority = { 's', 'n' },
    -- which direction previous/next items show up
    -- TODO: implement
    order = { n = 'bottom_up', s = 'top_down' },

    -- Whether to automatically show the window when new completion items are available
    auto_show = true,
    -- Delay before showing the completion menu
    auto_show_delay_ms = 0,

    -- Screen coordinates of the command line
    cmdline_position = function()
      if vim.g.ui_cmdline_pos ~= nil then
        local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
        return { pos[1] - 1, pos[2] }
      end
      local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
      return { vim.o.lines - height, 0 }
    end,

    -- Controls how the completion items are rendered on the popup window
    draw = {
      -- Aligns the keyword you've typed to a component in the menu
      align_to = 'label', -- or 'none' to disable
      -- Left and right padding, optionally { left, right } for different padding on each side
      padding = 1,
      -- Gap between columns
      gap = 1,
      -- Priority of the cursorline highlight, setting this to 0 will render it below other highlights
      cursorline_priority = 10000,
      -- Appends an indicator to snippets label, `'~'` by default
      snippet_indicator = '~',
      -- Use treesitter to highlight the label text of completions from these sources
      treesitter = {},
      -- Components to render, grouped by column
      columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
      -- Definitions for possible components to render. Each component defines:
      --   ellipsis: whether to add an ellipsis when truncating the text
      --   width: control the min, max and fill behavior of the component
      --   text function: will be called for each item
      --   highlight function: will be called only when the line appears on screen
      components = {
        kind_icon = {
          ellipsis = false,
          text = function(ctx) return ctx.kind_icon .. ctx.icon_gap end,
          -- Set the highlight priority to 20000 to beat the cursorline's default priority of 10000
          highlight = function(ctx) return { { group = ctx.kind_hl, priority = 20000 } } end,
        },

        kind = {
          ellipsis = false,
          width = { fill = true },
          text = function(ctx) return ctx.kind end,
          highlight = function(ctx) return ctx.kind_hl end,
        },

        label = {
          width = { fill = true, max = 60 },
          text = function(ctx) return ctx.label .. ctx.label_detail end,
          highlight = function(ctx)
            -- label and label details
            local label = ctx.label
            local highlights = {
              { 0, #label, group = ctx.deprecated and 'BlinkCmpLabelDeprecated' or 'BlinkCmpLabel' },
            }
            if ctx.label_detail then
              table.insert(highlights, { #label, #label + #ctx.label_detail, group = 'BlinkCmpLabelDetail' })
            end

            if vim.list_contains(ctx.self.treesitter, ctx.source_id) and not ctx.deprecated then
              -- add treesitter highlights
              vim.list_extend(highlights, require('blink.cmp.completion.windows.render.treesitter').highlight(ctx))
            end

            -- characters matched on the label by the fuzzy matcher
            for _, idx in ipairs(ctx.label_matched_indices) do
              table.insert(highlights, { idx, idx + 1, group = 'BlinkCmpLabelMatch' })
            end

            return highlights
          end,
        },

        label_description = {
          width = { max = 30 },
          text = function(ctx) return ctx.label_description end,
          highlight = 'BlinkCmpLabelDescription',
        },

        source_name = {
          width = { max = 30 },
          text = function(ctx) return ctx.source_name end,
          highlight = 'BlinkCmpSource',
        },

        source_id = {
          width = { max = 30 },
          text = function(ctx) return ctx.source_id end,
          highlight = 'BlinkCmpSource',
        },
      },
    },
  },
}

function window.validate(config)
  validate('completion.menu', {
    enabled = { config.enabled, 'boolean' },
    min_width = { config.min_width, 'number' },
    max_height = { config.max_height, 'number' },
    border = { config.border, { 'string', 'table' }, true },
    winblend = { config.winblend, 'number' },
    winhighlight = { config.winhighlight, 'string' },
    scrolloff = { config.scrolloff, 'number' },
    scrollbar = { config.scrollbar, 'boolean' },
    direction_priority = {
      config.direction_priority,
      function(direction_priority)
        if type(direction_priority) == 'function' then direction_priority = direction_priority() end
        for _, direction in ipairs(direction_priority) do
          if not vim.tbl_contains({ 'n', 's' }, direction) then return false end
        end
        return true
      end,
      'one of: "n", "s", or a function returning such a table',
    },
    order = { config.order, 'table' },
    auto_show = { config.auto_show, { 'boolean', 'function' } },
    auto_show_delay_ms = { config.auto_show_delay_ms, { 'number', 'function' } },
    cmdline_position = { config.cmdline_position, 'function' },
    draw = { config.draw, 'table' },
  }, config)
  validate('completion.menu.order', {
    n = { config.order.n, { 'string', 'nil' } },
    s = { config.order.s, { 'string', 'nil' } },
  }, config.order)

  validate('completion.menu.draw', {
    align_to = {
      config.draw.align_to,
      function(align)
        if type(config.draw.columns) == 'function' then return true end
        if align == 'none' or align == 'cursor' then return true end
        for _, column in ipairs(config.draw.columns) do
          for _, component in ipairs(column) do
            if component == align then return true end
          end
        end
        return false
      end,
      '"none" or one of the components defined in the "columns"',
    },

    padding = {
      config.draw.padding,
      function(padding)
        if type(padding) == 'number' then return true end
        if type(padding) ~= 'table' or #padding ~= 2 then return false end
        if type(padding[1]) == 'number' and type(padding[2]) == 'number' then return true end
        return false
      end,
      'a number or a tuple of 2 numbers, e.g. [1, 2]',
    },
    gap = { config.draw.gap, 'number' },
    cursorline_priority = { config.draw.cursorline_priority, 'number' },
    snippet_indicator = { config.draw.snippet_indicator, 'string' },

    treesitter = { config.draw.treesitter, 'table' },

    columns = {
      config.draw.columns,
      function(columns)
        local available_components = vim.tbl_keys(config.draw.components)
        if type(columns) == 'function' then return true end
        if type(columns) ~= 'table' or #columns == 0 then return false end
        for _, column in ipairs(columns) do
          if #column == 0 then return false end
          for _, component in ipairs(column) do
            if not vim.tbl_contains(available_components, component) then return false end
          end
          if column.gap ~= nil and type(column.gap) ~= 'number' then return false end
        end
        return true
      end,
      'a table of tables, where each table contains a list of components and an optional gap. List of available components: '
        .. table.concat(vim.tbl_keys(config.draw.components), ', '),
    },
    components = { config.draw.components, 'table' },
  }, config.draw)

  for component, definition in pairs(config.draw.components) do
    validate('completion.menu.draw.components.' .. component, {
      ellipsis = { definition.ellipsis, 'boolean', true },
      width = { definition.width, 'table', true },
      text = { definition.text, 'function' },
      highlight = { definition.highlight, { 'string', 'function' }, true },
    }, config.draw.components[component])
  end
end

return window

```

## lua/blink/cmp/config/completion/trigger.lua

```lua
--- @class (exact) blink.cmp.CompletionTriggerConfig
--- @field prefetch_on_insert boolean When true, will prefetch the completion items when entering insert mode. WARN: buggy, not recommended unless you'd like to help develop prefetching
--- @field show_in_snippet boolean When false, will not show the completion window when in a snippet
--- @field show_on_keyword boolean When true, will show the completion window after typing any of alphanumerics, `-` or `_`
--- @field show_on_backspace boolean When true, will show the completion window after backspacing
--- @field show_on_backspace_in_keyword boolean When true, will show the completion after backspacing into a keyword
--- @field show_on_backspace_after_accept boolean When true, will show the completion window after accepting a completion and then backspacing into a keyword
--- @field show_on_backspace_after_insert_enter boolean When true, will show the completion window after entering insert mode and backspacing into keyword
--- @field show_on_insert boolean When true, will show the completion window after entering insert mode
--- @field show_on_trigger_character boolean When true, will show the completion window after typing a trigger character
--- @field show_on_blocked_trigger_characters string[] | (fun(): string[]) LSPs can indicate when to show the completion window via trigger characters. However, some LSPs (e.g. tsserver) return characters that would essentially always show the window. We block these by default.
--- @field show_on_accept_on_trigger_character boolean When both this and show_on_trigger_character are true, will show the completion window when the cursor comes after a trigger character after accepting an item
--- @field show_on_insert_on_trigger_character boolean When both this and show_on_trigger_character are true, will show the completion window when the cursor comes after a trigger character when entering insert mode
--- @field show_on_x_blocked_trigger_characters string[] | (fun(): string[]) List of trigger characters (on top of `show_on_blocked_trigger_characters`) that won't trigger the completion window when the cursor comes after a trigger character when entering insert mode/accepting an item

local validate = require('blink.cmp.config.utils').validate
local trigger = {
  --- @type blink.cmp.CompletionTriggerConfig
  default = {
    prefetch_on_insert = false,
    show_in_snippet = true,
    show_on_keyword = true,
    show_on_backspace = false,
    show_on_backspace_in_keyword = false,
    show_on_backspace_after_accept = true,
    show_on_backspace_after_insert_enter = true,
    show_on_trigger_character = true,
    show_on_insert = false,
    show_on_blocked_trigger_characters = { ' ', '\n', '\t' },
    show_on_accept_on_trigger_character = true,
    show_on_insert_on_trigger_character = true,
    show_on_x_blocked_trigger_characters = { "'", '"', '(', '{', '[' },
  },
}

function trigger.validate(config)
  validate('completion.trigger', {
    prefetch_on_insert = { config.prefetch_on_insert, 'boolean' },
    show_in_snippet = { config.show_in_snippet, 'boolean' },
    show_on_backspace = { config.show_on_backspace, 'boolean' },
    show_on_backspace_in_keyword = { config.show_on_backspace_in_keyword, 'boolean' },
    show_on_backspace_after_accept = { config.show_on_backspace_after_accept, 'boolean' },
    show_on_backspace_after_insert_enter = { config.show_on_backspace_after_insert_enter, 'boolean' },
    show_on_keyword = { config.show_on_keyword, 'boolean' },
    show_on_trigger_character = { config.show_on_trigger_character, 'boolean' },
    show_on_insert = { config.show_on_insert, 'boolean' },
    show_on_blocked_trigger_characters = { config.show_on_blocked_trigger_characters, { 'function', 'table' } },
    show_on_accept_on_trigger_character = { config.show_on_accept_on_trigger_character, 'boolean' },
    show_on_insert_on_trigger_character = { config.show_on_insert_on_trigger_character, 'boolean' },
    show_on_x_blocked_trigger_characters = { config.show_on_x_blocked_trigger_characters, { 'function', 'table' } },
  }, config)
end

return trigger

```

## lua/blink/cmp/config/fuzzy.lua

```lua
--- @class (exact) blink.cmp.FuzzyConfig
--- @field implementation blink.cmp.FuzzyImplementationType Controls which implementation to use for the fuzzy matcher. See the documentation for the available values for more information.
--- @field max_typos number | fun(keyword: string): number Allows for a number of typos relative to the length of the query. Set this to 0 to match the behavior of fzf. Note, this does not apply when using the Lua implementation.
--- @field use_frecency boolean (deprecated) alias for frecency.enabled, will be removed in v2.0
--- @field use_unsafe_no_lock boolean (deprecated) alias for frecency.unsafe_no_lock, will be removed in v2.0
--- @field use_proximity boolean Boosts the score of items matching nearby words. Note, this does not apply when using the Lua implementation.
--- @field sorts blink.cmp.Sort[] Controls which sorts to use and in which order.
--- @field frecency blink.cmp.FuzzyFrecencyConfig Tracks the most recently/frequently used items and boosts the score of the item. Note, this does not apply when using the Lua implementation.
--- @field prebuilt_binaries blink.cmp.PrebuiltBinariesConfig

--- @class (exact) blink.cmp.FuzzyFrecencyConfig
--- @field enabled boolean Whether to enable the frecency feature
--- @field path string Location of the frecency database
--- @field unsafe_no_lock boolean UNSAFE!! When enabled, disables the lock and fsync when writing to the frecency database. This should only be used on unsupported platforms (e.g. alpine, termux).

--- @class (exact) blink.cmp.PrebuiltBinariesConfig
--- @field download boolean Whenther or not to automatically download a prebuilt binary from github. If this is set to `false`, you will need to manually build the fuzzy binary dependencies by running `cargo build --release`. Disabled by default when `fuzzy.implementation = 'lua'`
--- @field ignore_version_mismatch boolean Ignores mismatched version between the built binary and the current git sha, when building locally
--- @field force_version? string When downloading a prebuilt binary, force the downloader to resolve this version. If this is unset then the downloader will attempt to infer the version from the checked out git tag (if any). You may set this to any pattern that `git describe --tags --match <pattern>` supports. For example, to track the latest release, you may set this to `v*`. WARN: Beware that `main` may be incompatible with the version you select
--- @field force_system_triple? string When downloading a prebuilt binary, force the downloader to use this system triple. If this is unset then the downloader will attempt to infer the system triple from `jit.os` and `jit.arch`. Check the latest release for all available system triples. WARN: Beware that `main` may be incompatible with the version you select
--- @field extra_curl_args string[] Extra arguments that will be passed to curl like { 'curl', ..extra_curl_args, ..built_in_args }
--- @field proxy blink.cmp.PrebuiltBinariesProxyConfig

--- @class (exact) blink.cmp.PrebuiltBinariesProxyConfig
--- @field from_env boolean When downloading a prebuilt binary, use the HTTPS_PROXY environment variable
--- @field url? string When downloading a prebuilt binary, use this proxy URL. This will ignore the HTTPS_PROXY environment variable

--- @alias blink.cmp.FuzzyImplementationType
--- | 'prefer_rust_with_warning' (Recommended) If available, use the Rust implementation, automatically downloading prebuilt binaries on supported systems. Fallback to the Lua implementation when not available, emitting a warning message.
--- | 'prefer_rust' If available, use the Rust implementation, automatically downloading prebuilt binaries on supported systems. Fallback to the Lua implementation when not available.
--- | 'rust' Always use the Rust implementation, automatically downloading prebuilt binaries on supported systems. Error if not available.
--- | 'lua' Always use the Lua implementation

--- @alias blink.cmp.SortFunction fun(a: blink.cmp.CompletionItem, b: blink.cmp.CompletionItem): boolean | nil
--- @alias blink.cmp.Sort ("label" | "sort_text" | "kind" | "score" | "exact" | blink.cmp.SortFunction)

local validate = require('blink.cmp.config.utils').validate

local fuzzy = {
  --- @type blink.cmp.FuzzyConfig
  default = {
    implementation = 'prefer_rust_with_warning',
    max_typos = function(keyword) return math.floor(#keyword / 4) end,
    use_proximity = true,
    sorts = { 'score', 'sort_text' },
    frecency = {
      enabled = true,
      path = vim.fn.stdpath('state') .. '/blink/cmp/frecency.dat',
      unsafe_no_lock = false,
    },
    prebuilt_binaries = {
      download = true,
      ignore_version_mismatch = false,
      force_version = nil,
      force_system_triple = nil,
      extra_curl_args = {},
      proxy = {
        from_env = true,
        url = nil,
      },
    },
  },
}

function fuzzy.validate(config)
  -- TODO: Deprecations to be removed in v2.0
  if config.use_frecency ~= nil then
    vim.deprecate('fuzzy.use_frecency', 'fuzzy.frecency.enabled', 'v2.0.0', 'blink-cmp')
    config.frecency.enabled = config.use_frecency
    config.use_frecency = nil
  end
  if config.use_unsafe_no_lock ~= nil then
    vim.deprecate('fuzzy.use_unsafe_no_lock', 'fuzzy.frecency.unsafe_no_lock', 'v2.0.0', 'blink-cmp')
    config.frecency.unsafe_no_lock = config.use_unsafe_no_lock
    config.use_unsafe_no_lock = nil
  end

  validate('fuzzy', {
    implementation = {
      config.implementation,
      function(implementation)
        return vim.tbl_contains({ 'prefer_rust', 'prefer_rust_with_warning', 'rust', 'lua' }, implementation)
      end,
      'one of: "prefer_rust", "prefer_rust_with_warning", "rust", "lua"',
    },
    max_typos = { config.max_typos, { 'number', 'function' } },
    use_proximity = { config.use_proximity, 'boolean' },
    sorts = {
      config.sorts,
      function(sorts)
        if type(sorts) == 'function' then return true end
        if type(sorts) ~= 'table' then return false end
        for _, sort in ipairs(sorts) do
          if
            not vim.tbl_contains({ 'label', 'sort_text', 'kind', 'score', 'exact' }, sort)
            and type(sort) ~= 'function'
          then
            return false
          end
        end
        return true
      end,
      'one of: "label", "sort_text", "kind", "score", "exact" or a function',
    },
    frecency = { config.frecency, 'table' },
    prebuilt_binaries = { config.prebuilt_binaries, 'table' },
  }, config)

  validate('fuzzy.frecency', {
    enabled = { config.frecency.enabled, 'boolean' },
    path = { config.frecency.path, 'string' },
    unsafe_no_lock = { config.frecency.unsafe_no_lock, 'boolean' },
  }, config.frecency)

  validate('fuzzy.prebuilt_binaries', {
    download = { config.prebuilt_binaries.download, 'boolean' },
    ignore_version_mismatch = { config.prebuilt_binaries.ignore_version_mismatch, 'boolean' },
    force_version = { config.prebuilt_binaries.force_version, { 'string', 'nil' } },
    force_system_triple = { config.prebuilt_binaries.force_system_triple, { 'string', 'nil' } },
    extra_curl_args = { config.prebuilt_binaries.extra_curl_args, { 'table' } },
    proxy = { config.prebuilt_binaries.proxy, 'table' },
  }, config.prebuilt_binaries)

  validate('fuzzy.prebuilt_binaries.proxy', {
    from_env = { config.prebuilt_binaries.proxy.from_env, 'boolean' },
    url = { config.prebuilt_binaries.proxy.url, { 'string', 'nil' } },
  }, config.prebuilt_binaries.proxy)
end

return fuzzy

```

## lua/blink/cmp/config/init.lua

```lua
--- @class (exact) blink.cmp.ConfigStrict
--- @field enabled fun(): boolean | 'force' Enables keymaps, completions and signature help when true (doesn't apply to cmdline or term). If the function returns 'force', the default conditions for disabling the plugin will be ignored
--- @field keymap blink.cmp.KeymapConfig
--- @field completion blink.cmp.CompletionConfig
--- @field fuzzy blink.cmp.FuzzyConfig
--- @field sources blink.cmp.SourceConfig
--- @field signature blink.cmp.SignatureConfig
--- @field snippets blink.cmp.SnippetsConfig
--- @field appearance blink.cmp.AppearanceConfig
--- @field cmdline blink.cmp.CmdlineConfig
--- @field term blink.cmp.TermConfig

local validate = require('blink.cmp.config.utils').validate
--- @type blink.cmp.ConfigStrict
local config = {
  enabled = function() return true end,
  keymap = require('blink.cmp.config.keymap').default,
  completion = require('blink.cmp.config.completion').default,
  fuzzy = require('blink.cmp.config.fuzzy').default,
  sources = require('blink.cmp.config.sources').default,
  signature = require('blink.cmp.config.signature').default,
  snippets = require('blink.cmp.config.snippets').default,
  appearance = require('blink.cmp.config.appearance').default,

  -- mode specific configs
  cmdline = require('blink.cmp.config.modes.cmdline').default,
  term = require('blink.cmp.config.modes.term').default,
}

--- @type blink.cmp.ConfigStrict
--- @diagnostic disable-next-line: missing-fields
local M = {}

--- @param cfg blink.cmp.ConfigStrict
function M.validate(cfg)
  validate('config', {
    enabled = { cfg.enabled, 'function' },
    keymap = { cfg.keymap, 'table' },
    completion = { cfg.completion, 'table' },
    fuzzy = { cfg.fuzzy, 'table' },
    sources = { cfg.sources, 'table' },
    signature = { cfg.signature, 'table' },
    snippets = { cfg.snippets, 'table' },
    appearance = { cfg.appearance, 'table' },

    -- mode specific configs
    cmdline = { cfg.cmdline, 'table' },
    term = { cfg.term, 'table' },
  }, cfg)

  require('blink.cmp.config.keymap').validate(cfg.keymap)
  require('blink.cmp.config.completion').validate(cfg.completion)
  require('blink.cmp.config.fuzzy').validate(cfg.fuzzy)
  require('blink.cmp.config.sources').validate(cfg.sources)
  require('blink.cmp.config.signature').validate(cfg.signature)
  require('blink.cmp.config.snippets').validate(cfg.snippets)
  require('blink.cmp.config.appearance').validate(cfg.appearance)

  -- mode specific configs
  require('blink.cmp.config.modes.cmdline').validate(cfg.cmdline)
  require('blink.cmp.config.modes.term').validate(cfg.term)
end

--- @param cfg blink.cmp.ConfigStrict
function M.apply_mode_specific(cfg)
  local call_or_return = function(f, ...)
    if type(f) == 'function' then return f(...) end
    return f
  end

  local get_at_path = function(path)
    local t = cfg
    for _, p in ipairs(path) do
      if t == nil then return end
      t = t[p]
    end
    return t
  end

  local set_at_path = function(path, value)
    local t = cfg
    for i = 1, #path - 1 do
      t = t[path[i]]
    end
    t[path[#path]] = value
  end

  --- @param path string[]
  local apply_mode_specific_at_path = function(path)
    local default = get_at_path(path)
    local cmdline = get_at_path({ 'cmdline', unpack(path) })
    local term = get_at_path({ 'term', unpack(path) })

    if cmdline == nil and term == nil then return end

    set_at_path(path, function(...)
      local mode = vim.api.nvim_get_mode().mode
      if (mode == 'c' or vim.fn.win_gettype() == 'command') and cmdline ~= nil then
        return call_or_return(cmdline, ...)
      end
      if mode == 't' and term ~= nil then return call_or_return(term, ...) end
      return call_or_return(default, ...)
    end)
  end

  apply_mode_specific_at_path({ 'completion', 'trigger', 'show_on_blocked_trigger_characters' })
  apply_mode_specific_at_path({ 'completion', 'trigger', 'show_on_x_blocked_trigger_characters' })
  apply_mode_specific_at_path({ 'completion', 'list', 'selection', 'preselect' })
  apply_mode_specific_at_path({ 'completion', 'list', 'selection', 'auto_insert' })
  apply_mode_specific_at_path({ 'completion', 'menu', 'auto_show' })
  apply_mode_specific_at_path({ 'completion', 'menu', 'draw', 'columns' })
  apply_mode_specific_at_path({ 'completion', 'ghost_text', 'enabled' })
end

--- @param user_config blink.cmp.Config
function M.merge_with(user_config)
  config = vim.tbl_deep_extend('force', config, user_config)
  M.validate(config)
  M.apply_mode_specific(config)
end

--- Overrides

function M.enabled()
  -- disable in macros
  if vim.fn.reg_recording() ~= '' or vim.fn.reg_executing() ~= '' then return false end

  if vim.api.nvim_get_mode().mode == 'c' or vim.fn.win_gettype() == 'command' then return config.cmdline.enabled end
  if vim.api.nvim_get_mode().mode == 't' then return config.term.enabled end

  local user_enabled = config.enabled()
  -- User explicitly ignores default conditions
  if user_enabled == 'force' then return true end

  -- Buffer explicitly set completion to true, always enable
  if user_enabled and vim.b.completion == true then return true end

  -- Buffer explicitly set completion to false, always disable
  if vim.b.completion == false then return false end

  -- Exceptions
  if user_enabled and (vim.bo.filetype == 'dap-repl' or vim.startswith(vim.bo.filetype, 'dapui_')) then return true end

  return user_enabled and vim.bo.buftype ~= 'prompt' and vim.b.completion ~= false
end

--- @type blink.cmp.ConfigStrict
return setmetatable(M, {
  __index = function(_, k) return config[k] end,
})

```

## lua/blink/cmp/config/keymap.lua

````lua
--- @alias blink.cmp.KeymapCommand
--- | 'fallback' Fallback to mappings or the built-in behavior
--- | 'fallback_to_mappings' Fallback to mappings only (not built-in behavior)
--- | 'show' Show the completion window
--- | 'show_and_insert' Show the completion menu and insert the first item. Short form for `cmp.show({ initial_selected_item_idx = 1 })` when `auto_insert = true`
--- | 'show_and_insert_or_accept_single' Show the completion menu and insert the first item, or accepts the first item if there is only one
--- | 'hide' Hide the completion window
--- | 'cancel' Cancel the current completion, undoing the preview from auto_insert
--- | 'accept' Accept the current completion item
--- | 'accept_and_enter' Accept the current completion item and feed an enter key to neovim (e.g. to execute the current command in cmdline mode)
--- | 'select_and_accept' Select the first completion item, if there's no selection, and accept
--- | 'select_accept_and_enter' Select the first completion item, if there's no selection, accept and feed an enter key to neovim (e.g. to execute the current command in cmdline mode)
--- | 'select_prev' Select the previous completion item
--- | 'select_next' Select the next completion item
--- | 'insert_prev' Insert the previous completion item (`auto_insert`), cycling to the bottom of the list if at the top, if `completion.list.cycle.from_top == true`. This will trigger completions if none are available, unlike `select_prev` which would fallback to the next keymap in this case.
--- | 'insert_next' Insert the next completion item (`auto_insert`), cycling to the top of the list if at the bottom, if `completion.list.cycle.from_bottom == true`. This will trigger completions if none are available, unlike `select_next` which would fallback to the next keymap in this case.
--- | 'show_documentation' Show the documentation window
--- | 'hide_documentation' Hide the documentation window
--- | 'scroll_documentation_up' Scroll the documentation window up
--- | 'scroll_documentation_down' Scroll the documentation window down
--- | 'show_signature' Show the signature help window
--- | 'hide_signature' Hide the signature help window
--- | 'scroll_signature_up' Scroll the signature window up
--- | 'scroll_signature_down' Scroll the signature window down
--- | 'snippet_forward' Move the cursor forward to the next snippet placeholder
--- | 'snippet_backward' Move the cursor backward to the previous snippet placeholder
--- | (fun(cmp: blink.cmp.API): boolean | string | nil) Custom function where returning true will prevent the next command from running. Returning a string will insert the literal characters

--- @alias blink.cmp.KeymapPreset
--- | 'none' No keymaps
--- | 'inherit' Inherits the keymaps from the top level config. Only applicable to mode specific keymaps (i.e. cmdline, term)
--- Mappings similar to the built-in completion:
--- ```lua
--- {
---   ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
---   ['<C-e>'] = { 'cancel', 'fallback' },
---   ['<C-y>'] = { 'select_and_accept', 'fallback' },
---
---   ['<Up>'] = { 'select_prev', 'fallback' },
---   ['<Down>'] = { 'select_next', 'fallback' },
---   ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
---   ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
---
---   ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
---   ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
---
---   ['<Tab>'] = { 'snippet_forward', 'fallback' },
---   ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
---
---   ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
--- }
---
--- ```
--- | 'default'
--- Mappings similar to the built-in completion in cmdline mode:
--- ```lua
--- {
---   ['<Tab>'] = { 'show_and_insert_or_accept_single', 'select_next' },
---   ['<S-Tab>'] = { 'show_and_insert_or_accept_single', 'select_prev' },
---
---   ['<C-space>'] = { 'show', 'fallback' },
---
---   ['<C-n>'] = { 'select_next' },
---   ['<C-p>'] = { 'select_prev' },
---   ['<Right>'] = { 'select_next', 'fallback' },
---   ['<Left>'] = { 'select_prev', 'fallback' },
---
---   ['<C-y>'] = { 'select_and_accept', 'fallback' },
---   ['<C-e>'] = { 'cancel', 'fallback' },
---   ['<End>'] = { 'hide', 'fallback' },
--- }
--- ```
--- | 'cmdline'
--- Mappings similar to VSCode.
--- You may want to set `completion.trigger.show_in_snippet = false` or use `completion.list.selection.preselect = function(ctx) return not require('blink.cmp').snippet_active({ direction = 1 }) end` when using this mapping:
--- ```lua
--- {
---   ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
---   ['<C-e>'] = { 'cancel', 'fallback' },
---
---   ['<Tab>'] = {
---     function(cmp)
---       if cmp.snippet_active() then return cmp.accept()
---       else return cmp.select_and_accept() end
---     end,
---     'snippet_forward',
---     'fallback'
---   },
---   ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
---
---   ['<Up>'] = { 'select_prev', 'fallback' },
---   ['<Down>'] = { 'select_next', 'fallback' },
---   ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
---   ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
---
---   ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
---   ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
---
---   ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
--- }
--- ```
--- | 'super-tab'
--- Similar to 'super-tab' but with `enter` to accept
--- You may want to set `completion.list.selection.preselect = false` when using this keymap:
--- ```lua
--- {
---   ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
---   ['<C-e>'] = { 'cancel', 'fallback' },
---   ['<CR>'] = { 'accept', 'fallback' },
---
---   ['<Tab>'] = { 'snippet_forward', 'fallback' },
---   ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
---
---   ['<Up>'] = { 'select_prev', 'fallback' },
---   ['<Down>'] = { 'select_next', 'fallback' },
---   ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
---   ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
---
---   ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
---   ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
---
---   ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
--- }
--- ```
--- | 'enter'

--- Blink uses a special schema for defining keymaps since it needs to handle falling back to other mappings. However, there's nothing stopping you from using `require('blink.cmp')` and implementing these keymaps yourself.
--- Your custom key mappings are merged with a `preset` and any conflicting keys will overwrite the preset mappings. The `fallback` command will run the next non blink keymap.
---
--- Each keymap may be a list of commands and/or functions, where commands map directly to `require('blink.cmp')[command]()`. If the command/function returns `false` or `nil`, the next command/function will be run.
---
--- Example:
---
--- ```lua
--- keymap = {
---   -- set to 'none' to disable the 'default' preset
---   preset = 'default',
---
---   ['<Up>'] = { 'select_prev', 'fallback' },
---   ['<Down>'] = { 'select_next', 'fallback' },
---
---   -- disable a keymap from the preset
---   ['<C-e>'] = false,
---
---   -- show with a list of providers
---   ['<C-space>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },
---
---   -- control whether the next command will be run when using a function
---   ['<C-n>'] = {
---     function(cmp)
---       if some_condition then return end -- runs the next command
---       return true -- doesn't run the next command
---     end,
---     'select_next'
---   },
--- }
--- ```
---
--- When defining your own keymaps without a preset, no keybinds will be assigned automatically.
--- @class (exact) blink.cmp.KeymapConfig
--- @field preset? blink.cmp.KeymapPreset
--- @field [string] blink.cmp.KeymapCommand[] | false Table of keys => commands[] or false to disable

local keymap = {
  --- @type blink.cmp.KeymapConfig
  default = {
    preset = 'default',
  },
}

--- @param config blink.cmp.KeymapConfig
--- @param is_mode boolean? Is mode-specific keymap config
function keymap.validate(config, is_mode)
  assert(config.cmdline == nil, '`keymap.cmdline` has been replaced with `cmdline.keymap`')
  assert(config.term == nil, '`keymap.term` has been replaced with `term.keymap`')

  local commands = {
    'fallback',
    'fallback_to_mappings',
    'show',
    'show_and_insert',
    'show_and_insert_or_accept_single',
    'hide',
    'cancel',
    'accept',
    'accept_and_enter',
    'select_and_accept',
    'select_accept_and_enter',
    'select_prev',
    'select_next',
    'insert_prev',
    'insert_next',
    'show_documentation',
    'hide_documentation',
    'scroll_documentation_up',
    'scroll_documentation_down',
    'show_signature',
    'hide_signature',
    'scroll_signature_up',
    'scroll_signature_down',
    'snippet_forward',
    'snippet_backward',
  }
  local presets = { 'default', 'cmdline', 'super-tab', 'enter', 'none' }
  if is_mode then table.insert(presets, 'inherit') end

  local validation_schema = {}
  for key, value in pairs(config) do
    -- preset
    if key == 'preset' then
      validation_schema[key] = {
        value,
        function(preset) return vim.tbl_contains(presets, preset) end,
        'one of: ' .. table.concat(presets, ', '),
      }

    -- key
    else
      validation_schema[key] = {
        value,
        function(key_commands)
          if key_commands == false then return true end
          if type(key_commands) ~= 'table' then return false end
          for _, command in ipairs(key_commands) do
            if type(command) ~= 'function' and not vim.tbl_contains(commands, command) then return false end
          end
          return true
        end,
        'commands must be one of: ' .. table.concat(commands, ', ') .. ' or false to disable',
      }
    end
  end
  require('blink.cmp.config.utils')._validate(validation_schema)
end

return keymap

````

## lua/blink/cmp/config/modes/cmdline.lua

```lua
--- @class blink.cmp.CmdlineConfig : blink.cmp.ModeConfig

local cmdline = {
  --- @type blink.cmp.CmdlineConfig
  default = {
    enabled = true,
    keymap = { preset = 'cmdline' },
    sources = { 'buffer', 'cmdline' },
    completion = {
      trigger = { show_on_blocked_trigger_characters = {}, show_on_x_blocked_trigger_characters = {} },
      list = { selection = { preselect = true, auto_insert = true } },
      menu = { auto_show = function(ctx, _) return ctx.mode == 'cmdwin' end },
      ghost_text = { enabled = true },
    },
  },
}

--- @param config blink.cmp.CmdlineConfig
function cmdline.validate(config) require('blink.cmp.config.modes.types').validate('cmdline', config) end

return cmdline

```

## lua/blink/cmp/config/modes/term.lua

```lua
--- @class blink.cmp.TermConfig : blink.cmp.ModeConfig

local term = {
  --- @type blink.cmp.TermConfig
  default = {
    enabled = false,
    keymap = { preset = 'inherit' },
    sources = {},
    completion = {
      trigger = {
        show_on_blocked_trigger_characters = {},
      },
      menu = {
        draw = {
          columns = { { 'label', 'label_description', gap = 1 } },
        },
      },
    },
  },
}

--- @param config blink.cmp.TermConfig
function term.validate(config) require('blink.cmp.config.modes.types').validate('term', config) end

return term

```

## lua/blink/cmp/config/modes/types.lua

```lua
--- @class blink.cmp.ModeConfig
--- @field enabled? boolean
--- @field keymap blink.cmp.KeymapConfig
--- @field sources blink.cmp.SourceList
--- @field completion? blink.cmp.ModeCompletionConfig

--- @class blink.cmp.ModeCompletionConfig
--- @field trigger? blink.cmp.ModeCompletionTriggerConfig
--- @field list? blink.cmp.ModeCompletionListConfig
--- @field menu? blink.cmp.ModeCompletionMenuConfig
--- @field ghost_text? blink.cmp.ModeCompletionGhostTextConfig

--- @class blink.cmp.ModeCompletionListConfig
--- @field selection? blink.cmp.ModeCompletionListSelectionConfig

--- @class blink.cmp.ModeCompletionListSelectionConfig
--- @field preselect? boolean | fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): boolean Whether to preselect the first item when the list is shown
--- @field auto_insert? boolean | fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): boolean When `true`, inserts the completion item automatically when selecting it

--- @class blink.cmp.ModeCompletionTriggerConfig
--- @field show_on_blocked_trigger_characters? string[] | (fun(): string[]) LSPs can indicate when to show the completion window via trigger characters. However, some LSPs (e.g. tsserver) return characters that would essentially always show the window. We block these by default.
--- @field show_on_x_blocked_trigger_characters? string[] | (fun(): string[]) List of trigger characters (on top of `show_on_blocked_trigger_characters`) that won't trigger the completion window when the cursor comes after a trigger character when entering insert mode/accepting an item

--- @class blink.cmp.ModeCompletionMenuConfig
--- @field auto_show? boolean | fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): boolean Whether to automatically show the window when new completion items are available
--- @field draw? blink.cmp.ModeDraw Controls how the completion items are rendered on the popup window

--- @class blink.cmp.ModeDraw
--- @field columns? blink.cmp.DrawColumnDefinition[] | fun(context: blink.cmp.Context): blink.cmp.DrawColumnDefinition[] Components to render, grouped by column

--- @class blink.cmp.ModeCompletionGhostTextConfig
--- @field enabled? boolean | fun(): boolean

local validate = require('blink.cmp.config.utils').validate
local mode = {}

--- @param config blink.cmp.ModeConfig
function mode.validate(prefix, config)
  validate(prefix, {
    enabled = { config.enabled, 'boolean' },
    keymap = { config.keymap, 'table', true },
    sources = { config.sources, { 'function', 'table' } },
    completion = { config.completion, 'table', true },
  }, config)

  require('blink.cmp.config.keymap').validate(config.keymap, true)

  if config.completion ~= nil then
    validate(prefix .. '.completion', {
      trigger = { config.completion.trigger, 'table', true },
      list = { config.completion.list, 'table', true },
      menu = { config.completion.menu, 'table', true },
      ghost_text = { config.completion.ghost_text, 'table', true },
    }, config.completion)

    if config.completion.trigger ~= nil then
      validate(prefix .. '.completion.trigger', {
        show_on_blocked_trigger_characters = {
          config.completion.trigger.show_on_blocked_trigger_characters,
          { 'function', 'table' },
          true,
        },
        show_on_x_blocked_trigger_characters = {
          config.completion.trigger.show_on_x_blocked_trigger_characters,
          { 'function', 'table' },
          true,
        },
      }, config.completion.trigger)
    end

    if config.completion.list ~= nil then
      validate(prefix .. '.completion.list', {
        selection = { config.completion.list.selection, 'table', true },
      }, config.completion.list)

      if config.completion.list.selection ~= nil then
        validate(prefix .. '.completion.list.selection', {
          preselect = { config.completion.list.selection.preselect, { 'boolean', 'function' }, true },
          auto_insert = { config.completion.list.selection.auto_insert, { 'boolean', 'function' }, true },
        }, config.completion.list.selection)
      end
    end

    if config.completion.menu ~= nil then
      validate(prefix .. '.completion.menu', {
        auto_show = { config.completion.menu.auto_show, { 'boolean', 'function' }, true },
        draw = { config.completion.menu.draw, 'table', true },
      }, config.completion.menu)

      if config.completion.menu.draw ~= nil then
        validate(prefix .. '.completion.menu.draw', {
          columns = { config.completion.menu.draw.columns, { 'function', 'table' }, true },
        }, config.completion.menu.draw)
      end
    end

    if config.completion.ghost_text ~= nil then
      validate(prefix .. '.completion.ghost_text', {
        enabled = { config.completion.ghost_text.enabled, { 'boolean', 'function' }, true },
      }, config.completion.ghost_text)
    end
  end
end

return mode

```

## lua/blink/cmp/config/shared.lua

```lua
--- @alias blink.cmp.WindowBorderChar string | table
--- @alias blink.cmp.WindowBorder nil | 'single' | 'double' | 'rounded' | 'solid' | 'shadow' | 'bold' | 'padded' | 'none' | blink.cmp.WindowBorderChar[] When set to `nil`, uses the `vim.o.winborder` value on nvim 0.11+

```

## lua/blink/cmp/config/signature.lua

```lua
--- @class (exact) blink.cmp.SignatureConfig
--- @field enabled boolean
--- @field trigger blink.cmp.SignatureTriggerConfig
--- @field window blink.cmp.SignatureWindowConfig

--- @class (exact) blink.cmp.SignatureTriggerConfig
--- @field enabled boolean Show the signature help automatically
--- @field show_on_keyword boolean Show the signature help window after typing any of alphanumerics, `-` or `_`
--- @field blocked_trigger_characters string[]
--- @field blocked_retrigger_characters string[] When the signature help window has already been shown, don't update after typing these characters
--- @field show_on_trigger_character boolean Show the signature help window after typing a trigger character
--- @field show_on_insert boolean Show the signature help window when entering insert mode
--- @field show_on_insert_on_trigger_character boolean Show the signature help window when the cursor comes after a trigger character when entering insert mode
--- @field show_on_accept boolean Show the signature help window after accepting a completion item
--- @field show_on_accept_on_trigger_character boolean Show the signature help window when the cursor comes after a trigger character after accepting a completion item, e.g. func(|) where "(" is a trigger character

--- @class (exact) blink.cmp.SignatureWindowConfig
--- @field min_width number
--- @field max_width number
--- @field max_height number
--- @field border blink.cmp.WindowBorder
--- @field winblend number
--- @field winhighlight string
--- @field scrollbar boolean Note that the gutter will be disabled when border ~= 'none'
--- @field direction_priority ("n" | "s")[]| fun(): table Which directions to show the window ,or a function returning such a table, falling back to the next direction when there's not enough space, or another window is in the way.
--- @field treesitter_highlighting boolean Disable if you run into performance issues
--- @field show_documentation boolean

local validate = require('blink.cmp.config.utils').validate
local signature = {
  --- @type blink.cmp.SignatureConfig
  default = {
    enabled = false,
    trigger = {
      enabled = true,
      show_on_keyword = false,
      blocked_trigger_characters = {},
      blocked_retrigger_characters = {},
      show_on_trigger_character = true,
      show_on_insert = false,
      show_on_insert_on_trigger_character = true,
      show_on_accept = false,
      show_on_accept_on_trigger_character = true,
    },
    window = {
      min_width = 1,
      max_width = 100,
      max_height = 10,
      border = nil,
      winblend = 0,
      winhighlight = 'Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder',
      scrollbar = false,
      direction_priority = { 'n', 's' },
      treesitter_highlighting = true,
      show_documentation = false,
    },
  },
}

function signature.validate(config)
  validate('signature', {
    enabled = { config.enabled, 'boolean' },
    trigger = { config.trigger, 'table' },
    window = { config.window, 'table' },
  }, config)
  validate('signature.trigger', {
    enabled = { config.trigger.enabled, 'boolean' },
    show_on_keyword = { config.trigger.show_on_keyword, 'boolean' },
    blocked_trigger_characters = { config.trigger.blocked_trigger_characters, 'table' },
    blocked_retrigger_characters = { config.trigger.blocked_retrigger_characters, 'table' },
    show_on_trigger_character = { config.trigger.show_on_trigger_character, 'boolean' },
    show_on_insert = { config.trigger.show_on_insert, 'boolean' },
    show_on_insert_on_trigger_character = { config.trigger.show_on_insert_on_trigger_character, 'boolean' },
    show_on_accept = { config.trigger.show_on_accept, 'boolean' },
    show_on_accept_on_trigger_character = { config.trigger.show_on_accept_on_trigger_character, 'boolean' },
  }, config.trigger)
  validate('signature.window', {
    min_width = { config.window.min_width, 'number' },
    max_width = { config.window.max_width, 'number' },
    max_height = { config.window.max_height, 'number' },
    border = { config.window.border, { 'string', 'table' }, true },
    winblend = { config.window.winblend, 'number' },
    winhighlight = { config.window.winhighlight, 'string' },
    scrollbar = { config.window.scrollbar, 'boolean' },
    direction_priority = {
      config.window.direction_priority,
      function(direction_priority)
        if type(direction_priority) == 'function' then direction_priority = direction_priority() end
        for _, direction in ipairs(direction_priority) do
          if not vim.tbl_contains({ 'n', 's' }, direction) then return false end
        end
        return true
      end,
      'one of: "n", "s", or a function returning such a table',
    },
    treesitter_highlighting = { config.window.treesitter_highlighting, 'boolean' },
    show_documentation = { config.window.show_documentation, 'boolean' },
  }, config.window)
end

return signature

```

## lua/blink/cmp/config/snippets.lua

```lua
--- @class (exact) blink.cmp.SnippetsConfig
--- @field preset 'default' | 'luasnip' | 'mini_snippets' | 'vsnip'
--- @field expand fun(snippet: string) Function to use when expanding LSP provided snippets
--- @field active fun(filter?: { direction?: number }): boolean Function to use when checking if a snippet is active
--- @field jump fun(direction: number) Function to use when jumping between tab stops in a snippet, where direction can be negative or positive
--- @field score_offset number Offset to the score of all snippet items

--- @param handlers table<'default' | 'luasnip' | 'mini_snippets' | 'vsnip', fun(...): any>
local function by_preset(handlers)
  return function(...)
    local preset = require('blink.cmp.config').snippets.preset
    return handlers[preset](...)
  end
end

--- Guess whether we can expand an hidden luasnip snippet
--- @return boolean
local function is_hidden_snippet()
  local ls = require('luasnip')
  return not require('blink.cmp').is_visible() and not ls.locally_jumpable(1) and ls.expandable()
end

local validate = require('blink.cmp.config.utils').validate
local snippets = {
  --- @type blink.cmp.SnippetsConfig
  default = {
    preset = 'default',
    -- NOTE: we wrap `vim.snippet` calls to reduce startup by 1-2ms
    expand = by_preset({
      default = function(snippet) vim.snippet.expand(snippet) end,
      luasnip = function(snippet) require('luasnip').lsp_expand(snippet) end,
      mini_snippets = function(snippet)
        if not _G.MiniSnippets then error('mini.snippets has not been setup') end
        local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
        insert({ body = snippet })
        -- HACK: mini.snippets may edit the buffer during TextChangedI, so we need to ensure
        -- we run after it completes it callback. We do this by resubscribing to TextChangedI
        require('blink.cmp').resubscribe()
      end,
      vsnip = function(snippet) vim.fn['vsnip#anonymous'](snippet) end,
    }),
    active = by_preset({
      default = function(filter) return vim.snippet.active(filter) end,
      luasnip = function(filter)
        local ls = require('luasnip')
        if is_hidden_snippet() then return true end
        if filter and filter.direction then return ls.jumpable(filter.direction) end
        return ls.locally_jumpable(1)
      end,
      mini_snippets = function()
        if not _G.MiniSnippets then error('mini.snippets has not been setup') end
        return MiniSnippets.session.get(false) ~= nil
      end,
      vsnip = function() return vim.fn.empty(vim.fn['vsnip#get_session']()) ~= 1 end,
    }),
    jump = by_preset({
      default = function(direction) vim.snippet.jump(direction) end,
      luasnip = function(direction)
        local ls = require('luasnip')
        if is_hidden_snippet() then return ls.expand_or_jump() end
        return ls.jumpable(direction) and ls.jump(direction)
      end,
      mini_snippets = function(direction)
        if not _G.MiniSnippets then error('mini.snippets has not been setup') end
        MiniSnippets.session.jump(direction == -1 and 'prev' or 'next')
      end,
      vsnip = function(direction)
        if vim.fn['vsnip#jumpable'](direction) ~= 1 then return false end
        vim.cmd.call(string.format('vsnip#get_session().jump(%d)', direction))
        return true
      end,
    }),
    score_offset = -3,
  },
}

function snippets.validate(config)
  validate('snippets', {
    preset = {
      config.preset,
      function(preset) return vim.tbl_contains({ 'default', 'luasnip', 'mini_snippets', 'vsnip' }, preset) end,
      'one of: "default", "luasnip", "mini_snippets", "vsnip"',
    },
    expand = { config.expand, 'function' },
    active = { config.active, 'function' },
    jump = { config.jump, 'function' },
    score_offset = { config.score_offset, 'number' },
  }, config)
end

return snippets

```

## lua/blink/cmp/config/sources.lua

````lua
--- @class blink.cmp.SourceConfig
--- Static list of providers to enable, or a function to dynamically enable/disable providers based on the context
---
--- Example dynamically picking providers based on the filetype and treesitter node:
--- ```lua
---   function(ctx)
---     local node = vim.treesitter.get_node()
---     if vim.bo.filetype == 'lua' then
---       return { 'lsp', 'path' }
---     elseif node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
---       return { 'buffer' }
---     else
---       return { 'lsp', 'path', 'snippets', 'buffer' }
---     end
---   end
--- ```
--- @field default blink.cmp.SourceList
--- @field per_filetype table<string, blink.cmp.SourceListPerFiletype>
---
--- @field transform_items fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[] Function to transform the items before they're returned
--- @field min_keyword_length number | fun(ctx: blink.cmp.Context): number Minimum number of characters in the keyword to trigger
---
--- @field providers table<string, blink.cmp.SourceProviderConfig>

--- @alias blink.cmp.SourceList string[] | fun(): string[]
--- @alias blink.cmp.SourceListPerFiletype { inherit_defaults?: boolean, [number]: string } | fun(): ({ inherit_defaults?: boolean, [number]: string })

--- @class blink.cmp.SourceProviderConfig
--- @field module string
--- @field name? string
--- @field enabled? boolean | fun(): boolean Whether or not to enable the provider
--- @field opts? table
--- @field async? boolean | fun(ctx: blink.cmp.Context): boolean Whether we should show the completions before this provider returns, without waiting for it
--- @field timeout_ms? number | fun(ctx: blink.cmp.Context): number How long to wait for the provider to return before showing completions and treating it as asynchronous
--- @field transform_items? fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[] Function to transform the items before they're returned
--- @field should_show_items? boolean | fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): boolean Whether or not to show the items
--- @field max_items? number | fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): number Maximum number of items to display in the menu
--- @field min_keyword_length? number | fun(ctx: blink.cmp.Context): number Minimum number of characters in the keyword to trigger the provider
--- @field fallbacks? string[] | fun(ctx: blink.cmp.Context, enabled_sources: string[]): string[] If this provider returns 0 items, it will fallback to these providers
--- @field score_offset? number | fun(ctx: blink.cmp.Context, enabled_sources: string[]): number Boost/penalize the score of the items
--- @field deduplicate? blink.cmp.DeduplicateConfig TODO: implement
--- @field override? blink.cmp.SourceOverride Override the source's functions

local validate = require('blink.cmp.config.utils').validate
local sources = {
  --- @type blink.cmp.SourceConfig
  default = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    per_filetype = {},

    transform_items = function(_, items) return items end,
    min_keyword_length = 0,

    providers = {
      lsp = {
        name = 'LSP',
        module = 'blink.cmp.sources.lsp',
        fallbacks = { 'buffer' },
      },
      path = {
        module = 'blink.cmp.sources.path',
        score_offset = 3,
        fallbacks = { 'buffer' },
      },
      snippets = {
        module = 'blink.cmp.sources.snippets',
        score_offset = -1, -- receives a -3 from top level snippets.score_offset
      },
      buffer = {
        module = 'blink.cmp.sources.buffer',
        score_offset = -3,
      },
      cmdline = {
        module = 'blink.cmp.sources.cmdline',
      },
      omni = {
        module = 'blink.cmp.sources.complete_func',
        enabled = function() return vim.bo.omnifunc ~= 'v:lua.vim.lsp.omnifunc' end,
        ---@type blink.cmp.CompleteFuncOpts
        opts = {
          complete_func = function() return vim.bo.omnifunc end,
        },
      },
      -- NOTE: in the future, we may want a built-in terminal source. For now
      -- the infrastructure exists, so community terminal sources can be
      -- added, but this functionality is not baked into blink.cmp.
      -- term = { module = 'blink.cmp.sources.term' },
    },
  },
}

function sources.validate(config)
  assert(config.cmdline == nil, '`sources.cmdline` has been replaced with `cmdline.sources`')
  assert(config.term == nil, '`sources.term` has been replaced with `term.sources`')
  assert(
    config.providers.omni.module ~= 'blink.cmp.sources.omni',
    '`blink.cmp.sources.omni` has been replaced with `blink.cmp.sources.complete_func`'
  )

  validate('sources', {
    default = { config.default, { 'function', 'table' } },
    per_filetype = { config.per_filetype, 'table' },

    transform_items = { config.transform_items, 'function' },
    min_keyword_length = { config.min_keyword_length, { 'number', 'function' } },

    providers = { config.providers, 'table' },
  }, config)
  for id, provider in pairs(config.providers) do
    sources.validate_provider(id, provider)
  end
end

function sources.validate_provider(id, provider)
  assert(
    provider.fallback_for == nil,
    '`fallback_for` has been replaced with `fallbacks` which work in the opposite direction. For example, fallback_for = { "lsp" } on "buffer" would now be "fallbacks" = { "buffer" } on "lsp"'
  )

  validate('sources.providers.' .. id, {
    module = { provider.module, 'string' },
    name = { provider.name, 'string', true },
    enabled = { provider.enabled, { 'boolean', 'function' }, true },
    opts = { provider.opts, 'table', true },
    async = { provider.async, { 'boolean', 'function' }, true },
    timeout_ms = { provider.timeout_ms, { 'number', 'function' }, true },
    transform_items = { provider.transform_items, 'function', true },
    should_show_items = { provider.should_show_items, { 'boolean', 'function' }, true },
    max_items = { provider.max_items, { 'number', 'function' }, true },
    min_keyword_length = { provider.min_keyword_length, { 'number', 'function' }, true },
    fallbacks = { provider.fallback_for, { 'table', 'function' }, true },
    score_offset = { provider.score_offset, { 'number', 'function' }, true },
    deduplicate = { provider.deduplicate, 'table', true },
    override = { provider.override, 'table', true },
  }, provider)
end

return sources

````

## lua/blink/cmp/config/types_partial.lua

```lua
--- @class (exact) blink.cmp.Config : blink.cmp.ConfigStrict
--- @field enabled? fun(): boolean
--- @field keymap? blink.cmp.KeymapConfig
--- @field completion? blink.cmp.CompletionConfigPartial
--- @field fuzzy? blink.cmp.FuzzyConfigPartial
--- @field sources? blink.cmp.SourceConfigPartial
--- @field signature? blink.cmp.SignatureConfigPartial
--- @field snippets? blink.cmp.SnippetsConfigPartial
--- @field appearance? blink.cmp.AppearanceConfigPartial
--- @field cmdline? blink.cmp.CmdlineConfigPartial
--- @field term? blink.cmp.TermConfigPartial

--- @class (exact) blink.cmp.CompletionConfigPartial : blink.cmp.CompletionConfig
--- @field keyword? blink.cmp.CompletionKeywordConfigPartial
--- @field trigger? blink.cmp.CompletionTriggerConfigPartial
--- @field list? blink.cmp.CompletionListConfigPartial
--- @field accept? blink.cmp.CompletionAcceptConfigPartial
--- @field menu? blink.cmp.CompletionMenuConfigPartial
--- @field documentation? blink.cmp.CompletionDocumentationConfigPartial
--- @field ghost_text? blink.cmp.CompletionGhostTextConfigPartial

--- @class (exact) blink.cmp.CompletionKeywordConfigPartial : blink.cmp.CompletionKeywordConfig, {}

--- @class (exact) blink.cmp.CompletionTriggerConfigPartial : blink.cmp.CompletionTriggerConfig, {}

--- @class (exact) blink.cmp.CompletionListConfigPartial : blink.cmp.CompletionListConfig, {}
--- @field selection? blink.cmp.CompletionListSelectionConfigPartial
--- @field cycle? blink.cmp.CompletionListCycleConfigPartial

--- @class (exact) blink.cmp.CompletionListSelectionConfigPartial : blink.cmp.CompletionListSelectionConfig, {}

--- @class (exact) blink.cmp.CompletionListCycleConfigPartial : blink.cmp.CompletionListCycleConfig, {}

--- @class (exact) blink.cmp.CompletionAcceptConfigPartial : blink.cmp.CompletionAcceptConfig, {}
--- @field auto_brackets? blink.cmp.AutoBracketsConfigPartial

--- @class (exact) blink.cmp.AutoBracketsConfigPartial : blink.cmp.AutoBracketsConfig, {}
--- @field kind_resolution? blink.cmp.AutoBracketResolutionConfigPartial Synchronously use the kind of the item to determine if brackets should be added
--- @field semantic_token_resolution? blink.cmp.AutoBracketSemanticTokenResolutionConfigPartial Asynchronously use semantic token to determine if brackets should be added

--- @class (exact) blink.cmp.AutoBracketResolutionConfigPartial : blink.cmp.AutoBracketResolutionConfig, {}

--- @class (exact) blink.cmp.AutoBracketSemanticTokenResolutionConfigPartial : blink.cmp.AutoBracketSemanticTokenResolutionConfig, {}

--- @class (exact) blink.cmp.CompletionMenuConfigPartial : blink.cmp.CompletionMenuConfig, {}
--- @field order? blink.cmp.CompletionMenuOrderConfigPartial TODO: implement

--- @class (exact) blink.cmp.CompletionMenuOrderConfigPartial : blink.cmp.CompletionMenuOrderConfig, {}

--- @class (exact) blink.cmp.CompletionDocumentationConfigPartial : blink.cmp.CompletionDocumentationConfig, {}
--- @field window? blink.cmp.CompletionDocumentationWindowConfigPartial

--- @class (exact) blink.cmp.CompletionDocumentationWindowConfigPartial : blink.cmp.CompletionDocumentationWindowConfig, {}
--- @field direction_priority? blink.cmp.CompletionDocumentationDirectionPriorityConfigPartial Which directions to show the window, for each of the possible menu window directions, falling back to the next direction when there's not enough space

--- @class (exact) blink.cmp.CompletionDocumentationDirectionPriorityConfigPartial : blink.cmp.CompletionDocumentationDirectionPriorityConfig, {}

--- @class (exact) blink.cmp.CompletionGhostTextConfigPartial : blink.cmp.CompletionGhostTextConfig, {}

--- @class (exact) blink.cmp.FuzzyConfigPartial : blink.cmp.FuzzyConfig, {}
--- @field frecency? blink.cmp.FuzzyFrecencyConfigPartial
--- @field prebuilt_binaries? blink.cmp.PrebuiltBinariesConfigPartial

--- @class (exact) blink.cmp.FuzzyFrecencyConfigPartial : blink.cmp.FuzzyFrecencyConfig, {}

--- @class (exact) blink.cmp.PrebuiltBinariesConfigPartial : blink.cmp.PrebuiltBinariesConfig, {}
--- @field proxy? blink.cmp.PrebuiltBinariesProxyConfigPartial

--- @class (exact) blink.cmp.PrebuiltBinariesProxyConfigPartial : blink.cmp.PrebuiltBinariesProxyConfig, {}

--- @class blink.cmp.SourceConfigPartial : blink.cmp.SourceConfig, {}
--- @field providers? table<string, blink.cmp.SourceProviderConfigPartial>

--- @class blink.cmp.SourceProviderConfigPartial : blink.cmp.SourceProviderConfig, {}

--- @class (exact) blink.cmp.SignatureConfigPartial : blink.cmp.SignatureConfig, {}
--- @field trigger? blink.cmp.SignatureTriggerConfigPartial
--- @field window? blink.cmp.SignatureWindowConfigPartial

--- @class (exact) blink.cmp.SignatureTriggerConfigPartial : blink.cmp.SignatureTriggerConfig, {}

--- @class (exact) blink.cmp.SignatureWindowConfigPartial : blink.cmp.SignatureWindowConfig, {}

--- @class (exact) blink.cmp.SnippetsConfigPartial : blink.cmp.SnippetsConfig, {}

--- @class (exact) blink.cmp.AppearanceConfigPartial : blink.cmp.AppearanceConfig, {}

--- @class (exact) blink.cmp.CmdlineConfigPartial : blink.cmp.CmdlineConfig, {}

--- @class (exact) blink.cmp.TermConfigPartial : blink.cmp.TermConfig, {}

```

## lua/blink/cmp/config/utils.lua

```lua
local utils = {}

-- Code taken from @MariaSolOs in a indent-blankline.nvim PR:
-- https://github.com/lukas-reineke/indent-blankline.nvim/pull/934/files#diff-09ebcaa8c75cd1e92d25640e377ab261cfecaf8351c9689173fd36c2d0c23d94R16
-- Saves a whopping 20% compared to vim.validate (0.8ms -> 0.64ms)

--- Use the faster validate version if available
--- @param spec table<string, {[1]:any, [2]:function|string, [3]:string|true|nil}>
--- NOTE: We disable some Lua diagnostics here since lua_ls isn't smart enough to
--- realize that we're using an overloaded function.
function utils._validate(spec)
  if vim.fn.has('nvim-0.11') == 0 then return vim.validate(spec) end
  for key, key_spec in pairs(spec) do
    local message = type(key_spec[3]) == 'string' and key_spec[3] or nil --[[@as string?]]
    local optional = type(key_spec[3]) == 'boolean' and key_spec[3] or nil --[[@as boolean?]]
    vim.validate(key, key_spec[1], key_spec[2], optional, message)
  end
end

--- @param path string The path to the field being validated
--- @param tbl table The table to validate
--- @param source table The original table that we're validating against
--- @see vim.validate
function utils.validate(path, tbl, source)
  -- validate
  local _, err = pcall(utils._validate, tbl)
  -- remove stack trace from error message
  if err ~= nil and vim.fn.has('nvim-0.11') == 1 then
    local slice = require('blink.cmp.lib.utils').slice

    err = table.concat(slice(vim.split(err, ':'), 3), ':'):gsub('^%s+', '')
  end
  if err then error(path .. '.' .. err) end

  -- check for erroneous fields
  for k, _ in pairs(source) do
    if tbl[k] == nil then
      ---@type string[]
      local path_parts = vim.split(path, '.', { plain = true })
      local msg = {}

      for _, part in ipairs(path_parts) do
        table.insert(msg, { ' ' .. part .. ' ', 'DiagnosticVirtualTextInfo' })
        table.insert(msg, { ' → ' })
      end

      --- Highlight the last segment in ERROR since that's
      --- where the issue lies.
      table.insert(msg, { ' ' .. k .. ' ', 'DiagnosticVirtualTextError' })
      table.insert(msg, { ' Unexpected field in configuration!' })

      require('blink.cmp.lib.utils').notify(msg)
    end
  end
end

return utils

```

## LICENSE

```text
MIT License

Copyright (c) 2024 Liam Dyer

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
