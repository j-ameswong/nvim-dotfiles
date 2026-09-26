# markview.nvim defaults and configuration source

Commit: `190bb227c9d3eb4451b81fa16ea3d2efde2d67c5`

These are the upstream configuration sources at the locked commit. Defaults defined in code are reproduced verbatim; documentation is included for plugins whose settings are not expressed as one Lua table.

## lua/markview/config/asciidoc.lua

```lua
---@type [ string, markview.config.asciidoc.keycodes ]
local keycodes = {
	---|fS

	default = {
		padding_left = " ",
		padding_right = " ",

		icon = "󰌌 ",
		hl = "MarkviewPalette6",
	},

	ctrl = {
		icon = " ",
		hl = "MarkviewPalette3",
	},

	shift = {
		icon = "󰘶 ",
		hl = "MarkviewPalette4",
	},

	meta = {
		icon = "󰘵 ",
		hl = "MarkviewPalette2",
	},

	super = {
		icon = "󰌽 ",
		hl = "MarkviewPalette5",
	},

	command = {
		icon = "󰘳 ",
		hl = "MarkviewPalette5",
	},

	caps_lock = {
		icon = "󰘲 ",
		hl = "MarkviewPalette1",
	},

	space = {
		icon = "󱁐 ",
		hl = "MarkviewPalette5",
	},

	enter = {
		icon = "󰌑 ",
		hl = "MarkviewPalette2",
	},

	tab = {
		icon = "󰌒 ",
		hl = "MarkviewPalette3",
	},

	---|fE
};


---@type markview.config.asciidoc
return {
	enable = true,

	admonitions = {
		enable = true,

		default = {
			padding_left = " ",
			padding_right = " ",

			icon = " ",

			hl = "MarkviewPalette5",
		},

		important = {
			padding_left = " ",
			padding_right = " ",

			icon = " ",

			hl = "MarkviewPalette1",
		},

		tip = {
			padding_left = " ",
			padding_right = " ",

			icon = " ",

			hl = "MarkviewPalette4",
		},

		caution = {
			padding_left = " ",
			padding_right = " ",

			icon = " ",

			hl = "MarkviewPalette7",
		},

		warn = {
			padding_left = " ",
			padding_right = " ",

			icon = " ",

			hl = "MarkviewPalette3",
		},
	},

	block_quotes = {
		enable = true,

		default = {
			border = "▋",
			hl = "MarkviewBlockQuoteDefault"
		},
	},

	code_blocks = {
		enable = true,

		border_hl = "MarkviewCode",
		info_hl = "MarkviewCodeInfo",

		label_direction = "right",
		label_hl = nil,

		min_width = 60,
		pad_amount = 2,
		pad_char = " ",

		default = {
			block_hl = "MarkviewCode",
			pad_hl = "MarkviewCode"
		},

		["diff"] = {
			block_hl = function (_, line)
				if line:match("^%+") then
					return "MarkviewPalette4";
				elseif line:match("^%-") then
					return "MarkviewPalette1";
				else
					return "MarkviewCode";
				end
			end,
			pad_hl = "MarkviewCode"
		},

		style = "block",
		sign = true,
	},

	checkboxes = {
		enable = true,

		checked = { text = "󰗠", hl = "MarkviewCheckboxChecked", scope_hl = "MarkviewCheckboxChecked" },
		unchecked = { text = "󰄰", hl = "MarkviewCheckboxUnchecked", scope_hl = "MarkviewCheckboxUnchecked" },

		["/"] = { text = "󱎖", hl = "MarkviewCheckboxPending" },
		[">"] = { text = "", hl = "MarkviewCheckboxCancelled" },
		["<"] = { text = "󰃖", hl = "MarkviewCheckboxCancelled" },
		["-"] = { text = "󰍶", hl = "MarkviewCheckboxCancelled", scope_hl = "MarkviewCheckboxStriked" },

		["?"] = { text = "󰋗", hl = "MarkviewCheckboxPending" },
		["!"] = { text = "󰀦", hl = "MarkviewCheckboxUnchecked" },
		['"'] = { text = "󰸥", hl = "MarkviewCheckboxCancelled" },
		["l"] = { text = "󰆋", hl = "MarkviewCheckboxProgress" },
		["b"] = { text = "󰃀", hl = "MarkviewCheckboxProgress" },
		["i"] = { text = "󰰄", hl = "MarkviewCheckboxChecked" },
		["S"] = { text = "", hl = "MarkviewCheckboxChecked" },
		["I"] = { text = "󰛨", hl = "MarkviewCheckboxPending" },
		["p"] = { text = "", hl = "MarkviewCheckboxChecked" },
		["c"] = { text = "", hl = "MarkviewCheckboxUnchecked" },
		["f"] = { text = "󱠇", hl = "MarkviewCheckboxUnchecked" },
		["k"] = { text = "", hl = "MarkviewCheckboxPending" },
		["w"] = { text = "", hl = "MarkviewCheckboxProgress" },
		["u"] = { text = "󰔵", hl = "MarkviewCheckboxChecked" },
		["d"] = { text = "󰔳", hl = "MarkviewCheckboxUnchecked" },
	},

	delimited_blocks = {
		enable = true,

		hl = "MarkviewCode"
	},

	horizontal_rules = {
		enable = true,

		parts = {
			{
				type = "repeating",
				direction = "left",

				repeat_amount = function (buffer)
					local utils = require("markview.utils");
					local window = utils.buf_getwin(buffer)

					local width = vim.api.nvim_win_get_width(window)
					local textoff = vim.fn.getwininfo(window)[1].textoff;

					return math.floor((width - textoff - 3) / 2);
				end,

				text = "─",

				hl = {
					"MarkviewGradient1", "MarkviewGradient1",
					"MarkviewGradient2", "MarkviewGradient2",
					"MarkviewGradient3", "MarkviewGradient3",
					"MarkviewGradient4", "MarkviewGradient4",
					"MarkviewGradient5", "MarkviewGradient5",
					"MarkviewGradient6", "MarkviewGradient6",
					"MarkviewGradient7", "MarkviewGradient7",
					"MarkviewGradient8", "MarkviewGradient8",
					"MarkviewGradient9", "MarkviewGradient9"
				}
			},
			{
				type = "text",

				text = "  ",
				hl = "MarkviewIcon3Fg"
			},
			{
				type = "repeating",
				direction = "right",

				repeat_amount = function (buffer) --[[@as function]]
					local utils = require("markview.utils");
					local window = utils.buf_getwin(buffer)

					local width = vim.api.nvim_win_get_width(window)
					local textoff = vim.fn.getwininfo(window)[1].textoff;

					return math.ceil((width - textoff - 3) / 2);
				end,

				text = "─",
				hl = {
					"MarkviewGradient1", "MarkviewGradient1",
					"MarkviewGradient2", "MarkviewGradient2",
					"MarkviewGradient3", "MarkviewGradient3",
					"MarkviewGradient4", "MarkviewGradient4",
					"MarkviewGradient5", "MarkviewGradient5",
					"MarkviewGradient6", "MarkviewGradient6",
					"MarkviewGradient7", "MarkviewGradient7",
					"MarkviewGradient8", "MarkviewGradient8",
					"MarkviewGradient9", "MarkviewGradient9"
				}
			}
		}
	},

	literal_blocks = {
		enable = true,

		hl = "MarkviewCode",

		sign = "󱨏 ",
		sign_hl = "MarkviewPalette6Sign",

		label = "󱨏 Raw ",
		label_direction = "right",
		label_hl = "MarkviewIcon6",

		min_width = 60,
		pad_amount = 2,
		pad_char = " ",

		style = "block",
	},

	document_titles = {
		enable = true,

		sign = "󰛓 ",

		icon = "󰛓 ",
		hl = "MarkviewPalette7",
	},
	section_titles = {
		enable = true,

		title_1 = {
			sign = "󰌕 ", sign_hl = "MarkviewHeading1Sign",

			icon = "󰼏  ", hl = "MarkviewHeading1",
		},
		title_2 = {
			sign = "󰌖 ", sign_hl = "MarkviewHeading2Sign",

			icon = "󰎨  ", hl = "MarkviewHeading2",
		},
		title_3 = {

			icon = "󰼑  ", hl = "MarkviewHeading3",
		},
		title_4 = {

			icon = "󰎲  ", hl = "MarkviewHeading4",
		},
		title_5 = {

			icon = "󰼓  ", hl = "MarkviewHeading5",
		},
		title_6 = {

			icon = "󰎴  ", hl = "MarkviewHeading6",
		},

		shift_width = 1,
	},

	document_attributes = {
		enable = true,
	},

	images = {
		enable = true,

		default = {
			icon = "󰥶 ",
			hl = "MarkviewImage",
		},

		["%.svg$"] = { icon = "󰜡 " },
		["%.png$"] = { icon = "󰸭 " },
		["%.jpg$"] = { icon = "󰈥 " },
		["%.gif$"] = { icon = "󰵸 " },
		["%.pdf$"] = { icon = " " }
	},

	keycodes = {
		enable = true,

		default = keycodes.default,

		["^CTRL"] = keycodes.ctrl,
		["^%<[cC]"] = keycodes.ctrl,

		["^SHIFT"] = keycodes.shift,
		["^%<[sS]"] = keycodes.shift,

		["^META"] = keycodes.meta,
		["^OPT"] = keycodes.meta,
		["^ALT"] = keycodes.meta,
		["^%<[mM]"] = keycodes.meta,

		["^SUPER"] = keycodes.super,
		["^%<[dD]"] = keycodes.super,

		["^CMD"] = keycodes.command,
		["^COMMAND"] = keycodes.command,

		["CAPS.LOCK"] = keycodes.caps_lock,
		["SPACE"] = keycodes.space,
		["TAB"] = keycodes.tab,
		["ENTER"] = keycodes.enter,
	},

	list_items = {
		enable = true,
		shift_width = 4,

		marker_dot = {
			add_padding = true,
			conceal_on_checkboxes = true,

			text = function (_, item)
				return string.format("%d.", item.n);
			end,
			hl = "@markup.list.markdown",
		},

		marker_minus = {
			add_padding = true,
			conceal_on_checkboxes = true,

			text = "●",
			hl = "MarkviewListItemMinus"
		},

		marker_star = {
			add_padding = true,
			conceal_on_checkboxes = true,

			text = "◇",
			hl = "MarkviewListItemStar"
		},
	},

	tocs = {
		enable = true,

		shift_width = 2,
		hl = "MarkviewPalette2Fg",

		sign = "󰙅 ",
		sign_hl = "MarkviewPalette2Sign",

		depth_1 = {
			icon = "◆ ",
			icon_hl = "Comment",

			hl = "MarkviewPalette5Fg",
		},
		depth_2 = {
			icon = "◇ ",
			icon_hl = "Comment",

			hl = "MarkviewPalette5Fg",
		},
		depth_3 = {
			icon = "◆ ",
			icon_hl = "Comment",

			hl = "MarkviewPalette5Fg",
		},
		depth_4 = {
			icon = "◇ ",
			icon_hl = "Comment",

			hl = "MarkviewPalette5Fg",
		},
		depth_5 = {
			icon = "◆ ",
			icon_hl = "Comment",

			hl = "MarkviewPalette5Fg",
		},
	},
};

```

## lua/markview/config/asciidoc_inline.lua

```lua
local function normalize_str(str)
	if type(str) ~= "string" then
		return "";
	end

	return string.lower(str):gsub("^%l", string.upper);
end

---@type markview.config.asciidoc_inline
return {
	enable = true,

	bolds = { enable = true },

	highlights = {
		enable = true,

		default = {
			padding_left = " ",
			padding_right = " ",

			hl = "MarkviewPalette3"
		}
	},

	italics = { enable = true },

	monospaces = {
		enable = true,
		hl = "MarkviewInlineCode",

		padding_left = " ",
		padding_right = " "
	},

	uris = {
		enable = true,

		default = {
			icon = "󰌷 ",
			hl = "MarkviewHyperlink",
		},

		---|fS

		--NOTE(@OXY2DEV): Github sites.

		["github%.com/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return string.match(item.destination, "github%.com/([%a%d%-%_%.]+)%/?$");
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>
			icon = "󰳐 ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/?$");
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/tree/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>/tree/<branch>
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				local repo, branch = string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)/tree/([%a%d%-%_%.]+)%/?$");
				return repo .. " at " .. branch;
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/commits/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>/commits/<branch>
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+/commits/[%a%d%-%_%.]+)%/?$");
			end
		},

		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/releases$"] = {
			--- github.com/<user>/<repo>/releases
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return "Releases • " .. string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/releases$");
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/tags$"] = {
			--- github.com/<user>/<repo>/tags
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return "Tags • " .. string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/tags$");
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/issues$"] = {
			--- github.com/<user>/<repo>/issues
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return "Issues • " .. string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/issues$");
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/pulls$"] = {
			--- github.com/<user>/<repo>/pulls
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return "Pull requests • " .. string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/pulls$");
			end
		},

		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/wiki$"] = {
			--- github.com/<user>/<repo>/wiki
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return "Wiki • " .. string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/wiki$");
			end
		},

		--- NOTE(@OXY2DEV): Commonly used sites by programmers.

		["developer%.mozilla%.org"] = {
			priority = -9999,

			icon = "󰖟 ",
			hl = "MarkviewPalette5Fg"
		},

		["w3schools%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette4Fg"
		},

		["stackoverflow%.com"] = {
			priority = -9999,

			icon = "󰓌 ",
			hl = "MarkviewPalette2Fg"
		},

		["reddit%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["github%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["gitlab%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["dev%.to"] = {
			priority = -9999,

			icon = "󱁴 ",
			hl = "MarkviewPalette0Fg"
		},

		["codepen%.io"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["replit%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["jsfiddle%.net"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette5Fg"
		},

		["npmjs%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["pypi%.org"] = {
			priority = -9999,

			icon = "󰆦 ",
			hl = "MarkviewPalette0Fg"
		},

		["mvnrepository%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette1Fg"
		},

		["medium%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["linkedin%.com"] = {
			priority = -9999,

			icon = "󰌻 ",
			hl = "MarkviewPalette5Fg"
		},

		["news%.ycombinator%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["neovim%.io/doc/user/.*#%_?.*$"] = {
			icon = " ",
			hl = "MarkviewPalette4Fg",

			text = function (_, item)
				local file, tag = string.match(item.destination, "neovim%.io/doc/user/(.*)#%_?(.*)$");
				--- The actual website seems to show
				--- _ in the site name so, we won't
				--- be replacing `_`s with ` `s.
				file = string.gsub(file, "%.html$", "");

				return string.format("%s(%s) - Neovim docs", normalize_str(file), tag);
			end
		},
		["neovim%.io/doc/user/.*$"] = {
			icon = " ",
			hl = "MarkviewPalette4Fg",

			text = function (_, item)
				local file = string.match(item.destination, "neovim%.io/doc/user/(.*)$");
				file = string.gsub(file, "%.html$", "");

				return string.format("%s - Neovim docs", normalize_str(file));
			end
		},

		["github%.com/vim/vim"] = {
			priority = -100,

			icon = " ",
			hl = "MarkviewPalette4Fg",
		},

		["github%.com/neovim/neovim"] = {
			priority = -100,

			icon = " ",
			hl = "MarkviewPalette4Fg",
		},

		["vim%.org"] = {
			icon = " ",
			hl = "MarkviewPalette4Fg",
		},

		["luals%.github%.io/wiki/?.*$"] = {
			icon = " ",
			hl = "MarkviewPalette5Fg",

			text = function (_, item)
				if string.match(item.destination, "luals%.github%.io/wiki/(.-)/#(.+)$") then
					local page_mappings = {
						annotations = {
							["as"] = "@as",
							["alias"] = "@alias",
							["async"] = "@async",
							["cast"] = "@cast",
							["class"] = "@class",
							["deprecated"] = "@deprecated",
							["diagnostic"] = "@diagnostic",
							["enum"] = "@enum",
							["field"] = "@field",
							["generic"] = "@generic",
							["meta"] = "@meta",
							["module"] = "@module",
							["nodiscard"] = "@nodiscard",
							["operator"] = "@operator",
							["overload"] = "@overload",
							["package"] = "@package",
							["param"] = "@param",
							["see"] = "@see",
							["source"] = "@source",
							["type"] = "@type",
							["vaarg"] = "@vaarg",
							["version"] = "@version"
						}
					};

					local page, section = string.match(item.destination, "luals%.github%.io/wiki/(.-)/#(.+)$");

					if page_mappings[page] and page_mappings[page][section] then
						section = page_mappings[page][section];
					else
						section = normalize_str(string.gsub(section, "%-", " "));
					end

					return string.format("%s(%s) | Lua Language Server", normalize_str(page), section);
				elseif string.match(item.destination, "") then
					local page = string.match(item.destination, "luals%.github%.io/wiki/(.-)/?$");

					return string.format("%s | Lua Language Server", normalize_str(page));
				else
					return item.destination;
				end
			end
		},

		---|fE
	},
};

```

## lua/markview/config/comment.lua

```lua
local function normalize_str(str)
	if type(str) ~= "string" then
		return "";
	end

	return string.lower(str):gsub("^%l", string.upper);
end


---@type markview.config.comment
return {
	enable = true,

	autolinks = {
		enable = true,

		default = {
			icon = "󰋽 ",
			hl = "MarkviewPalette6",
		},

		---|fS

		--NOTE(@OXY2DEV): Github sites.

		["github%.com/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return string.match(item.destination, "github%.com/([%a%d%-%_%.]+)%/?$");
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>
			icon = "󰳐 ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/?$");
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/tree/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>/tree/<branch>
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				local repo, branch = string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)/tree/([%a%d%-%_%.]+)%/?$");
				return repo .. " at " .. branch;
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/commits/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>/commits/<branch>
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+/commits/[%a%d%-%_%.]+)%/?$");
			end
		},

		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/releases$"] = {
			--- github.com/<user>/<repo>/releases
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return "Releases • " .. string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/releases$");
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/tags$"] = {
			--- github.com/<user>/<repo>/tags
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return "Tags • " .. string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/tags$");
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/issues$"] = {
			--- github.com/<user>/<repo>/issues
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return "Issues • " .. string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/issues$");
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/pulls$"] = {
			--- github.com/<user>/<repo>/pulls
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return "Pull requests • " .. string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/pulls$");
			end
		},

		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/wiki$"] = {
			--- github.com/<user>/<repo>/wiki
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return "Wiki • " .. string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/wiki$");
			end
		},

		--- NOTE(@OXY2DEV): Commonly used sites by programmers.

		["developer%.mozilla%.org"] = {
			priority = -9999,

			icon = "󰖟 ",
			hl = "MarkviewPalette5Fg"
		},

		["w3schools%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette4Fg"
		},

		["stackoverflow%.com"] = {
			priority = -9999,

			icon = "󰓌 ",
			hl = "MarkviewPalette2Fg"
		},

		["reddit%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["github%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["gitlab%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["dev%.to"] = {
			priority = -9999,

			icon = "󱁴 ",
			hl = "MarkviewPalette0Fg"
		},

		["codepen%.io"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["replit%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["jsfiddle%.net"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette5Fg"
		},

		["npmjs%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["pypi%.org"] = {
			priority = -9999,

			icon = "󰆦 ",
			hl = "MarkviewPalette0Fg"
		},

		["mvnrepository%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette1Fg"
		},

		["medium%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["linkedin%.com"] = {
			priority = -9999,

			icon = "󰌻 ",
			hl = "MarkviewPalette5Fg"
		},

		["news%.ycombinator%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["neovim%.io/doc/user/.*#%_?.*$"] = {
			icon = " ",
			hl = "MarkviewPalette4Fg",

			text = function (_, item)
				local file, tag = string.match(item.destination, "neovim%.io/doc/user/(.*)#%_?(.*)$");
				--- The actual website seems to show
				--- _ in the site name so, we won't
				--- be replacing `_`s with ` `s.
				file = string.gsub(file, "%.html$", "");

				return string.format("%s(%s) - Neovim docs", normalize_str(file), tag);
			end
		},
		["neovim%.io/doc/user/.*$"] = {
			icon = " ",
			hl = "MarkviewPalette4Fg",

			text = function (_, item)
				local file = string.match(item.destination, "neovim%.io/doc/user/(.*)$");
				file = string.gsub(file, "%.html$", "");

				return string.format("%s - Neovim docs", normalize_str(file));
			end
		},

		["github%.com/vim/vim"] = {
			priority = -100,

			icon = " ",
			hl = "MarkviewPalette4Fg",
		},

		["github%.com/neovim/neovim"] = {
			priority = -100,

			icon = " ",
			hl = "MarkviewPalette4Fg",
		},

		["vim%.org"] = {
			icon = " ",
			hl = "MarkviewPalette4Fg",
		},

		["luals%.github%.io/wiki/?.*$"] = {
			icon = " ",
			hl = "MarkviewPalette5Fg",

			text = function (_, item)
				if string.match(item.destination, "luals%.github%.io/wiki/(.-)/#(.+)$") then
					local page_mappings = {
						annotations = {
							["as"] = "@as",
							["alias"] = "@alias",
							["async"] = "@async",
							["cast"] = "@cast",
							["class"] = "@class",
							["deprecated"] = "@deprecated",
							["diagnostic"] = "@diagnostic",
							["enum"] = "@enum",
							["field"] = "@field",
							["generic"] = "@generic",
							["meta"] = "@meta",
							["module"] = "@module",
							["nodiscard"] = "@nodiscard",
							["operator"] = "@operator",
							["overload"] = "@overload",
							["package"] = "@package",
							["param"] = "@param",
							["see"] = "@see",
							["source"] = "@source",
							["type"] = "@type",
							["vaarg"] = "@vaarg",
							["version"] = "@version"
						}
					};

					local page, section = string.match(item.destination, "luals%.github%.io/wiki/(.-)/#(.+)$");

					if page_mappings[page] and page_mappings[page][section] then
						section = page_mappings[page][section];
					else
						section = normalize_str(string.gsub(section, "%-", " "));
					end

					return string.format("%s(%s) | Lua Language Server", normalize_str(page), section);
				elseif string.match(item.destination, "") then
					local page = string.match(item.destination, "luals%.github%.io/wiki/(.-)/?$");

					return string.format("%s | Lua Language Server", normalize_str(page));
				else
					return item.destination;
				end
			end
		},

		---|fE
	},

	bolds = {
		enable = true,
	},

	code_blocks = {
		enable = true,

		border_hl = "MarkviewCode",
		info_hl = "MarkviewCodeInfo",

		label_direction = "right",
		label_hl = nil,

		min_width = 60,
		pad_amount = 2,
		pad_char = " ",

		default = {
			block_hl = "MarkviewCode",
			pad_hl = "MarkviewCode"
		},

		["diff"] = {
			block_hl = function (_, line)
				if line:match("^%+") then
					return "MarkviewPalette4";
				elseif line:match("^%-") then
					return "MarkviewPalette1";
				else
					return "MarkviewCode";
				end
			end,
			pad_hl = "MarkviewCode"
		},

		style = "block",
		sign = true,
	},

	inline_codes = {
		padding_left = " ",
		padding_right = " ",

		hl = "MarkviewInlineCode",
	},

	issues = {
		enable = true,

		default = {
			padding_left = " ",
			padding_right = " ",

			icon = " ",

			hl = "MarkviewPalette2",
		},
	},

	italics = {
		enable = true,
	},

	mentions = {
		enable = true,

		default = {
			padding_left = " ",
			padding_right = " ",

			icon = " ",

			hl = "MarkviewPalette5",
		},
	},

	taglinks = {
		enable = true,

		default = {
			padding_left = " ",
			padding_right = " ",

			icon = "󰌷 ",

			hl = "MarkviewHyperlink",
		},
	},

	tasks = {
		enable = true,

		default = {
			padding_left = " ",
			padding_right = " ",

			icon = "󰄰 ",

			hl = "MarkviewPalette1",
		},

		["^feat"] = {
			padding_left = " ",
			padding_right = " ",

			icon = "󱕅 ",

			hl = "MarkviewPalette7",
		},

		praise = {
			padding_left = " ",
			padding_right = " ",

			icon = "󱥋 ",

			hl = "MarkviewPalette3",
		},

		["^suggest"] = {
			padding_left = " ",
			padding_right = " ",

			icon = "󰣖 ",

			hl = "MarkviewPalette2",
		},

		thought = {
			padding_left = " ",
			padding_right = " ",

			icon = "󰧑 ",

			hl = "MarkviewPalette0",
		},

		note = {
			padding_left = " ",
			padding_right = " ",

			icon = "󰠮 ",

			hl = "MarkviewPalette5",
		},

		["^info"] = {
			padding_left = " ",
			padding_right = " ",

			icon = "󰋼 ",

			hl = "MarkviewPalette0",
		},

		xxx = {
			padding_left = " ",
			padding_right = " ",

			icon = "󰓽 ",

			hl = "MarkviewPalette0",
		},

		["^nit"] = {
			padding_left = " ",
			padding_right = " ",

			icon = "󰩰 ",

			hl = "MarkviewPalette6",
		},

		["^warn"] = {
			padding_left = " ",
			padding_right = " ",

			icon = " ",

			hl = "MarkviewPalette3",
		},

		fix = {
			padding_left = " ",
			padding_right = " ",

			icon = "󰁨 ",

			hl = "MarkviewPalette7",
		},

		hack = {
			padding_left = " ",
			padding_right = " ",

			icon = "󱍔 ",

			hl = "MarkviewPalette1",
		},

		typo = {
			padding_left = " ",
			padding_right = " ",

			icon = " ",

			hl = "MarkviewPalette0",
		},

		wip = {
			padding_left = " ",
			padding_right = " ",

			icon = "󰦖 ",

			hl = "MarkviewPalette2",
		},

		issue = {
			padding_left = " ",
			padding_right = " ",

			icon = " ",

			hl = "MarkviewPalette1",
		},

		["error"] = {
			padding_left = " ",
			padding_right = " ",

			icon = "󰅙 ",

			hl = "MarkviewPalette1",
		},

		fixme = {
			padding_left = " ",
			padding_right = " ",

			icon = "󰶯 ",

			hl = "MarkviewPalette4",
		},

		deprecated = {
			padding_left = " ",
			padding_right = " ",

			icon = "󰩆 ",

			hl = "MarkviewPalette1",
		},
	},

	task_scopes = {
		enable = true,

		default = {
			padding_left = " ",
			padding_right = " ",

			icon = "󰈲 ",

			hl = "MarkviewPalette4",
		},
	},

	urls = {
		enable = true,

		default = {
			icon = "󰌷 ",

			hl = "MarkviewHyperlink",
		},

		---|fS

		--NOTE(@OXY2DEV): Github sites.

		["github%.com/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return string.match(item.destination, "github%.com/([%a%d%-%_%.]+)%/?$");
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>
			icon = "󰳐 ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/?$");
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/tree/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>/tree/<branch>
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				local repo, branch = string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)/tree/([%a%d%-%_%.]+)%/?$");
				return repo .. " at " .. branch;
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/commits/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>/commits/<branch>
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+/commits/[%a%d%-%_%.]+)%/?$");
			end
		},

		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/releases$"] = {
			--- github.com/<user>/<repo>/releases
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return "Releases • " .. string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/releases$");
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/tags$"] = {
			--- github.com/<user>/<repo>/tags
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return "Tags • " .. string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/tags$");
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/issues$"] = {
			--- github.com/<user>/<repo>/issues
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return "Issues • " .. string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/issues$");
			end
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/pulls$"] = {
			--- github.com/<user>/<repo>/pulls
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return "Pull requests • " .. string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/pulls$");
			end
		},

		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/wiki$"] = {
			--- github.com/<user>/<repo>/wiki
			icon = " ",
			hl = "MarkviewPalette0Fg",

			text = function (_, item)
				return "Wiki • " .. string.match(item.destination, "github%.com/([%a%d%-%_%.]+/[%a%d%-%_%.]+)%/wiki$");
			end
		},

		--- NOTE(@OXY2DEV): Commonly used sites by programmers.

		["developer%.mozilla%.org"] = {
			priority = -9999,

			icon = "󰖟 ",
			hl = "MarkviewPalette5Fg"
		},

		["w3schools%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette4Fg"
		},

		["stackoverflow%.com"] = {
			priority = -9999,

			icon = "󰓌 ",
			hl = "MarkviewPalette2Fg"
		},

		["reddit%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["github%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["gitlab%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["dev%.to"] = {
			priority = -9999,

			icon = "󱁴 ",
			hl = "MarkviewPalette0Fg"
		},

		["codepen%.io"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["replit%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["jsfiddle%.net"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette5Fg"
		},

		["npmjs%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["pypi%.org"] = {
			priority = -9999,

			icon = "󰆦 ",
			hl = "MarkviewPalette0Fg"
		},

		["mvnrepository%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette1Fg"
		},

		["medium%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["linkedin%.com"] = {
			priority = -9999,

			icon = "󰌻 ",
			hl = "MarkviewPalette5Fg"
		},

		["news%.ycombinator%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["neovim%.io/doc/user/.*#%_?.*$"] = {
			icon = " ",
			hl = "MarkviewPalette4Fg",

			text = function (_, item)
				local file, tag = string.match(item.destination, "neovim%.io/doc/user/(.*)#%_?(.*)$");
				--- The actual website seems to show
				--- _ in the site name so, we won't
				--- be replacing `_`s with ` `s.
				file = string.gsub(file, "%.html$", "");

				return string.format("%s(%s) - Neovim docs", normalize_str(file), tag);
			end
		},
		["neovim%.io/doc/user/.*$"] = {
			icon = " ",
			hl = "MarkviewPalette4Fg",

			text = function (_, item)
				local file = string.match(item.destination, "neovim%.io/doc/user/(.*)$");
				file = string.gsub(file, "%.html$", "");

				return string.format("%s - Neovim docs", normalize_str(file));
			end
		},

		["github%.com/vim/vim"] = {
			priority = -100,

			icon = " ",
			hl = "MarkviewPalette4Fg",
		},

		["github%.com/neovim/neovim"] = {
			priority = -100,

			icon = " ",
			hl = "MarkviewPalette4Fg",
		},

		["vim%.org"] = {
			icon = " ",
			hl = "MarkviewPalette4Fg",
		},

		["luals%.github%.io/wiki/?.*$"] = {
			icon = " ",
			hl = "MarkviewPalette5Fg",

			text = function (_, item)
				if string.match(item.destination, "luals%.github%.io/wiki/(.-)/#(.+)$") then
					local page_mappings = {
						annotations = {
							["as"] = "@as",
							["alias"] = "@alias",
							["async"] = "@async",
							["cast"] = "@cast",
							["class"] = "@class",
							["deprecated"] = "@deprecated",
							["diagnostic"] = "@diagnostic",
							["enum"] = "@enum",
							["field"] = "@field",
							["generic"] = "@generic",
							["meta"] = "@meta",
							["module"] = "@module",
							["nodiscard"] = "@nodiscard",
							["operator"] = "@operator",
							["overload"] = "@overload",
							["package"] = "@package",
							["param"] = "@param",
							["see"] = "@see",
							["source"] = "@source",
							["type"] = "@type",
							["vaarg"] = "@vaarg",
							["version"] = "@version"
						}
					};

					local page, section = string.match(item.destination, "luals%.github%.io/wiki/(.-)/#(.+)$");

					if page_mappings[page] and page_mappings[page][section] then
						section = page_mappings[page][section];
					else
						section = normalize_str(string.gsub(section, "%-", " "));
					end

					return string.format("%s(%s) | Lua Language Server", normalize_str(page), section);
				elseif string.match(item.destination, "") then
					local page = string.match(item.destination, "luals%.github%.io/wiki/(.-)/?$");

					return string.format("%s | Lua Language Server", normalize_str(page));
				else
					return item.destination;
				end
			end
		},

		---|fE
	},
};

```

## lua/markview/config/html.lua

```lua
return {
	enable = true,

	container_elements = {
		enable = true,

		["^a$"] = {
			on_opening_tag = { conceal = "", virt_text_pos = "inline", virt_text = { { " ", "MarkviewHyperlink" } } },
			on_node = { hl_group = "MarkviewHyperlink" },
			on_closing_tag = { conceal = "" },
		},
		["^b$"] = {
			on_opening_tag = { conceal = "" },
			on_node = { hl_group = "Bold" },
			on_closing_tag = { conceal = "" },
		},
		["^code$"] = {
			on_opening_tag = { conceal = "", hl_mode = "combine", virt_text_pos = "inline", virt_text = { { " ", "MarkviewInlineCode" } } },
			on_node = { hl_group = "MarkviewInlineCode" },
			on_closing_tag = { conceal = "", hl_mode = "combine", virt_text_pos = "inline", virt_text = { { " ", "MarkviewInlineCode" } } },
		},
		["^em$"] = {
			on_opening_tag = { conceal = "" },
			on_node = { hl_group = "@text.emphasis" },
			on_closing_tag = { conceal = "" },
		},
		["^i$"] = {
			on_opening_tag = { conceal = "" },
			on_node = { hl_group = "Italic" },
			on_closing_tag = { conceal = "" },
		},
		["^kbd$"] = function (_, item)
			local hl = "MarkviewInlineCode";
			local output = {
				on_opening_tag = { conceal = "" },
				on_node = {
					virt_text_pos = "inline",
					right_gravity = true,
					hl_group = hl
				},
				on_closing_tag = { conceal = "", hl_mode = "combine", virt_text_pos = "inline", virt_text = { { " ", hl } } },
			};

			if not item then
				return output;
			end

			---@type integer Start column of the node.
			local start_col = item.range.col_start;

			---@type integer[] Output of `TSNode:range()` on the opening tag.
			local open_range = item.opening_tag.range;
			---@type integer[] Output of `TSNode:range()` on the closing tag.
			local close_range = item.closing_tag.range;

			---@type string Normalized keymap.
			local key = string.upper(
				string.sub(
					item.text[1],
					(open_range[4] + 1) - start_col,
					close_range[2] - start_col
				)
			);

			if string.match(key, "^%<C") or string.match(key, "CTRL") then
				hl = "MarkviewPalette3";

				output.on_node.hl_group = hl;
				output.on_node.virt_text = { { "  ", hl } };
				output.on_closing_tag.virt_text = { { " ", hl } };
			elseif string.match(key, "^%<S") or string.match(key, "SHIFT") then
				hl = "MarkviewPalette4";

				output.on_node.hl_group = hl;
				output.on_node.virt_text = { { " 󰘶 ", hl } };
				output.on_closing_tag.virt_text = { { " ", hl } };
			elseif
				string.match(key, "^%<M") or
				string.match(key, "OPT") or string.match(key, "OPTION") or
				string.match(key, "ALT") or string.match(key, "META")
			then
				hl = "MarkviewPalette2";

				output.on_node.hl_group = hl;
				output.on_node.virt_text = { { " 󰘵 ", hl } };
				output.on_closing_tag.virt_text = { { " ", hl } };
			elseif string.match(key, "^%<D") or string.match(key, "SUPER") then
				hl = "MarkviewPalette5";

				output.on_node.hl_group = hl;
				output.on_node.virt_text = { { " 󰌽 ", hl } };
				output.on_closing_tag.virt_text = { { " ", hl } };
			elseif string.match(key, "CMD") or string.match(key, "COMMAND") then
				hl = "MarkviewPalette5";

				output.on_node.hl_group = hl;
				output.on_node.virt_text = { { " 󰘳 ", hl } };
				output.on_closing_tag.virt_text = { { " ", hl } };
			elseif string.match(key, "CAPS.LOCK") then
				hl = "MarkviewPalette1";

				output.on_node.hl_group = hl;
				output.on_node.virt_text = { { " 󰘲 ", hl } };
				output.on_closing_tag.virt_text = { { " ", hl } };
			elseif string.match(key, "SPACE") then
				hl = "MarkviewPalette5";

				output.on_node.hl_group = hl;
				output.on_node.virt_text = { { " 󱁐 ", hl } };
				output.on_closing_tag.virt_text = { { " ", hl } };
			elseif string.match(key, "ENTER") then
				hl = "MarkviewPalette2";

				output.on_node.hl_group = hl;
				output.on_node.virt_text = { { " 󰌑 ", hl } };
				output.on_closing_tag.virt_text = { { " ", hl } };
			elseif string.match(key, "TAB") then
				hl = "MarkviewPalette3";

				output.on_node.hl_group = hl;
				output.on_node.virt_text = { { " 󰌒 ", hl } };
				output.on_closing_tag.virt_text = { { " ", hl } };
			else
				hl = "MarkviewPalette6";

				output.on_node.hl_group = hl;
				output.on_node.virt_text = { { " 󰌌 ", hl } };
				output.on_closing_tag.virt_text = { { " ", hl } };
			end

			return output;
		end,
		["^mark$"] = {
			on_opening_tag = { conceal = "" },
			on_node = { hl_group = "MarkviewPalette1" },
			on_closing_tag = { conceal = "" },
		},
		["^pre$"] = {
			on_opening_tag = { conceal = "" },
			on_node = { hl_group = "Special" },
			on_closing_tag = { conceal = "" },
		},
		["^strong$"] = {
			on_opening_tag = { conceal = "" },
			on_node = { hl_group = "@text.strong" },
			on_closing_tag = { conceal = "" },
		},
		["^sub$"] = {
			on_opening_tag = { conceal = "", hl_mode = "combine", virt_text_pos = "inline", virt_text = { { "↓[", "MarkviewSubscript" } } },
			on_node = { hl_group = "MarkviewSubscript" },
			on_closing_tag = { conceal = "", hl_mode = "combine", virt_text_pos = "inline", virt_text = { { "]", "MarkviewSubscript" } } },
		},
		["^sup$"] = {
			on_opening_tag = { conceal = "", hl_mode = "combine", virt_text_pos = "inline", virt_text = { { "↑[", "MarkviewSuperscript" } } },
			on_node = { hl_group = "MarkviewSuperscript" },
			on_closing_tag = { conceal = "", hl_mode = "combine", virt_text_pos = "inline", virt_text = { { "]", "MarkviewSuperscript" } } },
		},
		["^u$"] = {
			on_opening_tag = { conceal = "" },
			on_node = { hl_group = "Underlined" },
			on_closing_tag = { conceal = "" },
		},
	},

	headings = {
		enable = true,

		heading_1 = {
			hl_group = "MarkviewPalette1Bg"
		},
		heading_2 = {
			hl_group = "MarkviewPalette2Bg"
		},
		heading_3 = {
			hl_group = "MarkviewPalette3Bg"
		},
		heading_4 = {
			hl_group = "MarkviewPalette4Bg"
		},
		heading_5 = {
			hl_group = "MarkviewPalette5Bg"
		},
		heading_6 = {
			hl_group = "MarkviewPalette6Bg"
		},
	},

	void_elements = {
		enable = true,

		["^hr$"] = {
			on_node = {
				conceal = "",

				virt_text_pos = "inline",
				virt_text = {
					{ "─", "MarkviewGradient2" },
					{ "─", "MarkviewGradient3" },
					{ "─", "MarkviewGradient4" },
					{ "─", "MarkviewGradient5" },
					{ " ◉ ", "MarkviewGradient9" },
					{ "─", "MarkviewGradient5" },
					{ "─", "MarkviewGradient4" },
					{ "─", "MarkviewGradient3" },
					{ "─", "MarkviewGradient2" },
				}
			}
		},
		["^br$"] = {
			on_node = {
				conceal = "",

				virt_text_pos = "inline",
				virt_text = {
					{ "󱞦", "Comment" },
				}
			}
		},
	}
};

```

## lua/markview/config/latex.lua

```lua
--- Creates a configuration table for a LaTeX command.
---@param name string Command name(Text to show).
---@param text_pos? "overlay" | "inline" `virt_text_pos` extmark options.
---@param cmd_conceal? integer Characters to conceal.
---@param cmd_hl? string Highlight group for the command.
---@return markview.config.latex.commands.opts
local operator = function (name, text_pos, cmd_conceal, cmd_hl)
	return {
		condition = function (item)
			return #item.args <= 1;
		end,

		on_command = function (item)
			local symbols = require("markview.symbols");

			return {
				end_col = item.range[2] + (cmd_conceal or 1),
				conceal = "",

				virt_text_pos = text_pos or "overlay",
				virt_text = {
					{ symbols.tostring("default", name), cmd_hl or "@keyword.function" }
				},

				hl_mode = "combine"
			}
		end,

		on_args = {
			{
				on_before = function (item)
					return {
						end_col = item.range[2] + 1,

						virt_text_pos = "overlay",
						virt_text = {
							{ "(", "@punctuation.bracket" }
						},

						hl_mode = "combine"
					}
				end,

				after_offset = function (range)
					return { range[1], range[2], range[3], range[4] - 1 };
				end,

				on_after = function (item)
					return {
						end_col = item.range[4],

						virt_text_pos = "overlay",
						virt_text = {
							{ ")", "@punctuation.bracket" }
						},

						hl_mode = "combine"
					}
				end
			}
		}
	};
end

return {
	enable = true,

	blocks = {
		enable = true,

		hl = "MarkviewCode",
		pad_char = " ",
		pad_amount = 3,

		text = "  LaTeX ",
		text_hl = "MarkviewCodeInfo"
	},

	commands = {
		enable = true,

		["boxed"] = {
			condition = function (item)
				return #item.args == 1;
			end,
			on_command = {
				conceal = ""
			},

			on_args = {
				{
					on_before = function (item)
						return {
							end_col = item.range[2] + 1,
							conceal = "",

							virt_text_pos = "inline",
							virt_text = {
								{ " ", "MarkviewPalette4Fg" },
								{ "[", "@punctuation.bracket.latex" }
							},

							hl_mode = "combine"
						}
					end,

					after_offset = function (range)
						return { range[1], range[2], range[3], range[4] - 1 };
					end,
					on_after = function (item)
						return {
							end_col = item.range[4],
							conceal = "",

							virt_text_pos = "inline",
							virt_text = {
								{ "]", "@punctuation.bracket" }
							},

							hl_mode = "combine"
						}
					end
				}
			}
		},
		["frac"] = {
			condition = function (item)
				return #item.args == 2;
			end,
			on_command = {
				conceal = ""
			},

			on_args = {
				{
					on_before = function (item)
						return {
							end_col = item.range[2] + 1,
							conceal = "",

							virt_text_pos = "inline",
							virt_text = {
								{ "(", "@punctuation.bracket" }
							},

							hl_mode = "combine"
						}
					end,

					after_offset = function (range)
						return { range[1], range[2], range[3], range[4] - 1 };
					end,
					on_after = function (item)
						return {
							end_col = item.range[4],
							conceal = "",

							virt_text_pos = "inline",
							virt_text = {
								{ ")", "@punctuation.bracket" },
								{ " ÷ ", "@keyword.function" }
							},

							hl_mode = "combine"
						}
					end
				},
				{
					on_before = function (item)
						return {
							end_col = item.range[2] + 1,
							conceal = "",

							virt_text_pos = "inline",
							virt_text = {
								{ "(", "@punctuation.bracket" }
							},

							hl_mode = "combine"
						}
					end,

					after_offset = function (range)
						return { range[1], range[2], range[3], range[4] - 1 };
					end,
					on_after = function (item)
						return {
							end_col = item.range[4],
							conceal = "",

							virt_text_pos = "inline",
							virt_text = {
								{ ")", "@punctuation.bracket" },
							},

							hl_mode = "combine"
						}
					end
				},
			}
		},

		["vec"] = {
			condition = function (item)
				return #item.args == 1;
			end,
			on_command = {
				conceal = ""
			},

			on_args = {
				{
					on_before = function (item)
						return {
							end_col = item.range[2] + 1,
							conceal = "",

							virt_text_pos = "inline",
							virt_text = {
								{ "󱈥 ", "MarkviewPalette2Fg" },
								{ "(", "@punctuation.bracket.latex" }
							},

							hl_mode = "combine"
						}
					end,

					after_offset = function (range)
						return { range[1], range[2], range[3], range[4] - 1 };
					end,
					on_after = function (item)
						return {
							end_col = item.range[4],
							conceal = "",

							virt_text_pos = "inline",
							virt_text = {
								{ ")", "@punctuation.bracket" }
							},

							hl_mode = "combine"
						}
					end
				}
			}
		},

		["sin"] = operator("sin"),
		["cos"] = operator("cos"),
		["tan"] = operator("tan"),

		["sinh"] = operator("sinh"),
		["cosh"] = operator("cosh"),
		["tanh"] = operator("tanh"),

		["csc"] = operator("csc"),
		["sec"] = operator("sec"),
		["cot"] = operator("cot"),

		["csch"] = operator("csch"),
		["sech"] = operator("sech"),
		["coth"] = operator("coth"),

		["arcsin"] = operator("arcsin"),
		["arccos"] = operator("arccos"),
		["arctan"] = operator("arctan"),

		["arg"] = operator("arg"),
		["deg"] = operator("deg"),
		["det"] = operator("det"),
		["dim"] = operator("dim"),
		["exp"] = operator("exp"),
		["gcd"] = operator("gcd"),
		["hom"] = operator("hom"),
		["inf"] = operator("inf"),
		["ker"] = operator("ker"),
		["lg"] = operator("lg"),

		["lim"] = operator("lim"),
		["liminf"] = operator("lim inf", "inline", 7),
		["limsup"] = operator("lim sup", "inline", 7),

		["ln"] = operator("ln"),
		["log"] = operator("log"),
		["min"] = operator("min"),
		["max"] = operator("max"),
		["Pr"] = operator("Pr"),
		["sup"] = operator("sup"),

		---@diagnostic disable:assign-type-mismatch
		["sqrt"] = function ()
			local symbols = require("markview.symbols");
			return operator(symbols.entries.sqrt, "inline", 5);
		end,
		["lvert"] = function ()
			local symbols = require("markview.symbols");
			return operator(symbols.entries.vert, "inline", 6);
		end,
		["lVert"] = function ()
			local symbols = require("markview.symbols");
			return operator(symbols.entries.Vert, "inline", 6);
		end,
		---@diagnostic enable:assign-type-mismatch
	},

	escapes = {
		enable = true
	},

	fonts = {
		enable = true,

		default = {
			enable = true,
			hl = "MarkviewSpecial"
		},

		mathbf = { enable = true },
		mathbfit = { enable = true },
		mathcal = { enable = true },
		mathscr = { enable = true },
		mathbfscr = { enable = true },
		mathfrak = { enable = true },
		mathbb = { enable = true },
		mathbffrak = { enable = true },
		mathsf = { enable = true },
		mathsfbf = { enable = true },
		mathsfit = { enable = true },
		mathsfbfit = { enable = true },
		mathtt = { enable = true },
		mathrm = { enable = true },
	},

	inlines = {
		enable = true,

		padding_left = " ",
		padding_right = " ",

		hl = "MarkviewInlineCode"
	},

	parenthesis = {
		enable = true,
	},

	subscripts = {
		enable = true,

		hl = "MarkviewSubscript"
	},

	superscripts = {
		enable = true,

		hl = "MarkviewSuperscript"
	},

	symbols = {
		enable = true,

		hl = "MarkviewComment"
	},

	texts = {
		enable = true
	},
};

```

## lua/markview/config/markdown.lua

```lua
---@type markview.config.markdown
return {
	enable = true,

	block_quotes = {
		enable = true,
		wrap = true,

		default = {
			border = "▋",
			hl = "MarkviewBlockQuoteDefault"
		},

		["ABSTRACT"] = {
			preview = "󱉫 Abstract",
			hl = "MarkviewBlockQuoteNote",

			title = true,
			icon = "󱉫",
		},
		["SUMMARY"] = {
			hl = "MarkviewBlockQuoteNote",
			preview = "󱉫 Summary",

			title = true,
			icon = "󱉫",
		},
		["TLDR"] = {
			hl = "MarkviewBlockQuoteNote",
			preview = "󱉫 Tldr",

			title = true,
			icon = "󱉫",
		},
		["TODO"] = {
			hl = "MarkviewBlockQuoteNote",
			preview = " Todo",

			title = true,
			icon = "",
		},
		["INFO"] = {
			hl = "MarkviewBlockQuoteNote",
			preview = " Info",

			custom_title = true,
			icon = "",
		},
		["SUCCESS"] = {
			hl = "MarkviewBlockQuoteOk",
			preview = "󰗠 Success",

			title = true,
			icon = "󰗠",
		},
		["CHECK"] = {
			hl = "MarkviewBlockQuoteOk",
			preview = "󰗠 Check",

			title = true,
			icon = "󰗠",
		},
		["DONE"] = {
			hl = "MarkviewBlockQuoteOk",
			preview = "󰗠 Done",

			title = true,
			icon = "󰗠",
		},
		["QUESTION"] = {
			hl = "MarkviewBlockQuoteWarn",
			preview = "󰋗 Question",

			title = true,
			icon = "󰋗",
		},
		["HELP"] = {
			hl = "MarkviewBlockQuoteWarn",
			preview = "󰋗 Help",

			title = true,
			icon = "󰋗",
		},
		["FAQ"] = {
			hl = "MarkviewBlockQuoteWarn",
			preview = "󰋗 Faq",

			title = true,
			icon = "󰋗",
		},
		["FAILURE"] = {
			hl = "MarkviewBlockQuoteError",
			preview = "󰅙 Failure",

			title = true,
			icon = "󰅙",
		},
		["FAIL"] = {
			hl = "MarkviewBlockQuoteError",
			preview = "󰅙 Fail",

			title = true,
			icon = "󰅙",
		},
		["MISSING"] = {
			hl = "MarkviewBlockQuoteError",
			preview = "󰅙 Missing",

			title = true,
			icon = "󰅙",
		},
		["DANGER"] = {
			hl = "MarkviewBlockQuoteError",
			preview = " Danger",

			title = true,
			icon = "",
		},
		["ERROR"] = {
			hl = "MarkviewBlockQuoteError",
			preview = " Error",

			title = true,
			icon = "",
		},
		["BUG"] = {
			hl = "MarkviewBlockQuoteError",
			preview = " Bug",

			title = true,
			icon = "",
		},
		["EXAMPLE"] = {
			hl = "MarkviewBlockQuoteSpecial",
			preview = "󱖫 Example",

			title = true,
			icon = "󱖫",
		},
		["QUOTE"] = {
			hl = "MarkviewBlockQuoteDefault",
			preview = " Quote",

			title = true,
			icon = "",
		},
		["CITE"] = {
			hl = "MarkviewBlockQuoteDefault",
			preview = " Cite",

			title = true,
			icon = "",
		},
		["HINT"] = {
			hl = "MarkviewBlockQuoteOk",
			preview = " Hint",

			title = true,
			icon = "",
		},
		["ATTENTION"] = {
			hl = "MarkviewBlockQuoteWarn",
			preview = " Attention",

			title = true,
			icon = "",
		},

		["NOTE"] = {
			hl = "MarkviewBlockQuoteNote",
			preview = "󰋽 Note",

			title = true,
			icon = "󰋽",
		},
		["TIP"] = {
			hl = "MarkviewBlockQuoteOk",
			preview = " Tip",

			title = true,
			icon = "",
		},
		["IMPORTANT"] = {
			hl = "MarkviewBlockQuoteSpecial",
			preview = " Important",

			title = true,
			icon = "",
		},
		["WARNING"] = {
			hl = "MarkviewBlockQuoteWarn",
			preview = " Warning",

			title = true,
			icon = "",
		},
		["CAUTION"] = {
			hl = "MarkviewBlockQuoteError",
			preview = "󰳦 Caution",

			title = true,
			icon = "󰳦",
		}
	},

	code_blocks = {
		enable = true,

		border_hl = "MarkviewCode",
		info_hl = "MarkviewCodeInfo",

		label_direction = "right",
		label_hl = nil,

		min_width = 60,
		pad_amount = 2,
		pad_char = " ",

		default = {
			block_hl = "MarkviewCode",
			pad_hl = "MarkviewCode"
		},

		["diff"] = {
			block_hl = function (_, line)
				if line:match("^%+") then
					return "MarkviewPalette4";
				elseif line:match("^%-") then
					return "MarkviewPalette1";
				else
					return "MarkviewCode";
				end
			end,
			pad_hl = "MarkviewCode"
		},

		style = function (buf)
			if vim.o.wrap then
				return "simple";
			end

			local win = require("markview.utils").buf_getwin(buf);
			return vim.wo[win].wrap == true and "simple" or "block";
		end,
		sign = true,
	},

	headings = {
		enable = true,

		heading_1 = {
			style = "icon",
			sign = "󰌕 ", sign_hl = "MarkviewHeading1Sign",

			icon = "󰼏  ", hl = "MarkviewHeading1",
		},
		heading_2 = {
			style = "icon",
			sign = "󰌖 ", sign_hl = "MarkviewHeading2Sign",

			icon = "󰎨  ", hl = "MarkviewHeading2",
		},
		heading_3 = {
			style = "icon",

			icon = "󰼑  ", hl = "MarkviewHeading3",
		},
		heading_4 = {
			style = "icon",

			icon = "󰎲  ", hl = "MarkviewHeading4",
		},
		heading_5 = {
			style = "icon",

			icon = "󰼓  ", hl = "MarkviewHeading5",
		},
		heading_6 = {
			style = "icon",

			icon = "󰎴  ", hl = "MarkviewHeading6",
		},

		setext_1 = {
			style = "decorated",

			sign = "󰌕 ", sign_hl = "MarkviewHeading1Sign",
			icon = "  ", hl = "MarkviewHeading1",
			border = "▂"
		},
		setext_2 = {
			style = "decorated",

			sign = "󰌖 ", sign_hl = "MarkviewHeading2Sign",
			icon = "  ", hl = "MarkviewHeading2",
			border = "▁"
		},

		shift_width = 1,

		org_indent = false,
		org_indent_wrap = true,
		org_shift_char = " ",
		org_shift_width = 1,
	},

	horizontal_rules = {
		enable = true,

		parts = {
			{
				type = "repeating",
				direction = "left",

				repeat_amount = function (buffer)
					local utils = require("markview.utils");
					local window = utils.buf_getwin(buffer)

					local width = vim.api.nvim_win_get_width(window)
					local textoff = vim.fn.getwininfo(window)[1].textoff;

					return math.floor((width - textoff - 3) / 2);
				end,

				text = "─",

				hl = {
					"MarkviewGradient1", "MarkviewGradient1",
					"MarkviewGradient2", "MarkviewGradient2",
					"MarkviewGradient3", "MarkviewGradient3",
					"MarkviewGradient4", "MarkviewGradient4",
					"MarkviewGradient5", "MarkviewGradient5",
					"MarkviewGradient6", "MarkviewGradient6",
					"MarkviewGradient7", "MarkviewGradient7",
					"MarkviewGradient8", "MarkviewGradient8",
					"MarkviewGradient9", "MarkviewGradient9"
				}
			},
			{
				type = "text",

				text = "  ",
				hl = "MarkviewIcon3Fg"
			},
			{
				type = "repeating",
				direction = "right",

				repeat_amount = function (buffer) --[[@as function]]
					local utils = require("markview.utils");
					local window = utils.buf_getwin(buffer)

					local width = vim.api.nvim_win_get_width(window)
					local textoff = vim.fn.getwininfo(window)[1].textoff;

					return math.ceil((width - textoff - 3) / 2);
				end,

				text = "─",
				hl = {
					"MarkviewGradient1", "MarkviewGradient1",
					"MarkviewGradient2", "MarkviewGradient2",
					"MarkviewGradient3", "MarkviewGradient3",
					"MarkviewGradient4", "MarkviewGradient4",
					"MarkviewGradient5", "MarkviewGradient5",
					"MarkviewGradient6", "MarkviewGradient6",
					"MarkviewGradient7", "MarkviewGradient7",
					"MarkviewGradient8", "MarkviewGradient8",
					"MarkviewGradient9", "MarkviewGradient9"
				}
			}
		}
	},

	list_items = {
		enable = true,
		wrap = true,

		indent_size = function (buffer)
			if type(buffer) ~= "number" then
				return vim.bo.shiftwidth or 4;
			end

			--- Use 'shiftwidth' value.
			return vim.bo[buffer].shiftwidth or 4;
		end,
		shift_width = 4,

		marker_minus = {
			add_padding = true,
			conceal_on_checkboxes = true,

			text = "●",
			hl = "MarkviewListItemMinus"
		},

		marker_plus = {
			add_padding = true,
			conceal_on_checkboxes = true,

			text = "◈",
			hl = "MarkviewListItemPlus"
		},

		marker_star = {
			add_padding = true,
			conceal_on_checkboxes = true,

			text = "◇",
			hl = "MarkviewListItemStar"
		},

		marker_dot = {
			text = function (_, item)
				return string.format("%d.", item.n);
			end,
			hl = "@markup.list.markdown",
			add_padding = true,
			conceal_on_checkboxes = true
		},

		marker_parenthesis = {
			text = function (_, item)
				return string.format("%d)", item.n);
			end,
			hl = "@markup.list.markdown",
			add_padding = true,
			conceal_on_checkboxes = true
		}
	},

	metadata_minus = {
		enable = true,

		hl = "MarkviewCode",
		border_hl = "MarkviewCodeFg",

		border_top = "▄",
		border_bottom = "▀"
	},

	metadata_plus = {
		enable = true,

		hl = "MarkviewCode",
		border_hl = "MarkviewCodeFg",

		border_top = "▄",
		border_bottom = "▀"
	},

	reference_definitions = {
		enable = true,

		default = {
			icon = " ",
			hl = "MarkviewPalette4Fg"
		},

		["github%.com/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/tree/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>/tree/<branch>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/commits/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>/commits/<branch>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/releases$"] = {
			--- github.com/<user>/<repo>/releases

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/tags$"] = {
			--- github.com/<user>/<repo>/tags

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/issues$"] = {
			--- github.com/<user>/<repo>/issues

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/pulls$"] = {
			--- github.com/<user>/<repo>/pulls

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/wiki$"] = {
			--- github.com/<user>/<repo>/wiki

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["developer%.mozilla%.org"] = {
			priority = -9999,

			icon = "󰖟 ",
			hl = "MarkviewPalette5Fg"
		},

		["w3schools%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette4Fg"
		},

		["stackoverflow%.com"] = {
			priority = -9999,

			icon = "󰓌 ",
			hl = "MarkviewPalette2Fg"
		},

		["reddit%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["github%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["gitlab%.com"] = {
			priority = -9999,

			icon = "󰮠 ",
			hl = "MarkviewPalette2Fg"
		},

		["dev%.to"] = {
			priority = -9999,

			icon = "󱁴 ",
			hl = "MarkviewPalette0Fg"
		},

		["codepen%.io"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["replit%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["jsfiddle%.net"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette5Fg"
		},

		["npmjs%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["pypi%.org"] = {
			priority = -9999,

			icon = "󰆦 ",
			hl = "MarkviewPalette0Fg"
		},

		["mvnrepository%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette1Fg"
		},

		["medium%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["linkedin%.com"] = {
			priority = -9999,

			icon = "󰌻 ",
			hl = "MarkviewPalette5Fg"
		},

		["news%.ycombinator%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},
	},

	tables = {
		enable = true,
		strict = false,

		block_decorator = true,
		use_virt_lines = false,

		parts = {
			top = { "╭", "─", "╮", "┬" },
			header = { "│", "│", "│" },
			separator = { "├", "─", "┤", "┼" },
			row = { "│", "│", "│" },
			bottom = { "╰", "─", "╯", "┴" },

			overlap = { "┝", "━", "┥", "┿" },

			align_left = "╼",
			align_right = "╾",
			align_center = { "╴", "╶" }
		},

		hl = {
			top = { "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader" },
			header = { "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader" },
			separator = { "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader" },
			row = { "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder" },
			bottom = { "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder" },

			overlap = { "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder" },

			align_left = "MarkviewTableAlignLeft",
			align_right = "MarkviewTableAlignRight",
			align_center = { "MarkviewTableAlignCenter", "MarkviewTableAlignCenter" }
		}
	},
};

```

## lua/markview/config/markdown_inline.lua

```lua
---@type markview.config.markdown_inline
return {
	enable = true,

	block_references = {
		enable = true,

		default = {
			icon = "󰿨 ",

			hl = "MarkviewPalette6Fg",
			file_hl = "MarkviewPalette0Fg",
		},
	},

	checkboxes = {
		enable = true,

		checked = { text = "󰗠", hl = "MarkviewCheckboxChecked", scope_hl = "MarkviewCheckboxChecked" },
		unchecked = { text = "󰄰", hl = "MarkviewCheckboxUnchecked", scope_hl = "MarkviewCheckboxUnchecked" },

		["/"] = { text = "󱎖", hl = "MarkviewCheckboxPending" },
		[">"] = { text = "", hl = "MarkviewCheckboxCancelled" },
		["<"] = { text = "󰃖", hl = "MarkviewCheckboxCancelled" },
		["-"] = { text = "󰍶", hl = "MarkviewCheckboxCancelled", scope_hl = "MarkviewCheckboxStriked" },

		["?"] = { text = "󰋗", hl = "MarkviewCheckboxPending" },
		["!"] = { text = "󰀦", hl = "MarkviewCheckboxUnchecked" },
		["*"] = { text = "󰓎", hl = "MarkviewCheckboxPending" },
		['"'] = { text = "󰸥", hl = "MarkviewCheckboxCancelled" },
		["l"] = { text = "󰆋", hl = "MarkviewCheckboxProgress" },
		["b"] = { text = "󰃀", hl = "MarkviewCheckboxProgress" },
		["i"] = { text = "󰰄", hl = "MarkviewCheckboxChecked" },
		["S"] = { text = "", hl = "MarkviewCheckboxChecked" },
		["I"] = { text = "󰛨", hl = "MarkviewCheckboxPending" },
		["p"] = { text = "", hl = "MarkviewCheckboxChecked" },
		["c"] = { text = "", hl = "MarkviewCheckboxUnchecked" },
		["f"] = { text = "󱠇", hl = "MarkviewCheckboxUnchecked" },
		["k"] = { text = "", hl = "MarkviewCheckboxPending" },
		["w"] = { text = "", hl = "MarkviewCheckboxProgress" },
		["u"] = { text = "󰔵", hl = "MarkviewCheckboxChecked" },
		["d"] = { text = "󰔳", hl = "MarkviewCheckboxUnchecked" },
	},

	emails = {
		enable = true,

		default = {
			icon = " ",
			hl = "MarkviewEmail"
		},

		["%@gmail%.com$"] = {
			--- user@gmail.com

			icon = "󰊫 ",
			hl = "MarkviewPalette0Fg"
		},

		["%@outlook%.com$"] = {
			--- user@outlook.com

			icon = "󰴢 ",
			hl = "MarkviewPalette5Fg"
		},

		["%@yahoo%.com$"] = {
			--- user@yahoo.com

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["%@icloud%.com$"] = {
			--- user@icloud.com

			icon = "󰀸 ",
			hl = "MarkviewPalette6Fg"
		}
	},

	embed_files = {
		enable = true,

		default = {
			icon = "󰠮 ",
			hl = "MarkviewPalette7Fg"
		}
	},

	entities = {
		enable = true,
		hl = "Special"
	},

	emoji_shorthands = {
		enable = true
	},

	escapes = {
		enable = true
	},

	footnotes = {
		enable = true,

		default = {
			icon = "󰯓 ",
			hl = "MarkviewHyperlink"
		},

		["^%d+$"] = {
			--- Numbered footnotes.

			icon = "󰯓 ",
			hl = "MarkviewPalette4Fg"
		}
	},

	highlights = {
		enable = true,

		default = {
			padding_left = " ",
			padding_right = " ",

			hl = "MarkviewPalette3"
		}
	},

	hyperlinks = {
		enable = true,

		default = {
			icon = "󰌷 ",
			hl = "MarkviewHyperlink",
		},

		["github%.com/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/tree/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>/tree/<branch>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/commits/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>/commits/<branch>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/releases$"] = {
			--- github.com/<user>/<repo>/releases

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/tags$"] = {
			--- github.com/<user>/<repo>/tags

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/issues$"] = {
			--- github.com/<user>/<repo>/issues

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/pulls$"] = {
			--- github.com/<user>/<repo>/pulls

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/wiki$"] = {
			--- github.com/<user>/<repo>/wiki

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["developer%.mozilla%.org"] = {
			priority = -9999,

			icon = "󰖟 ",
			hl = "MarkviewPalette5Fg"
		},

		["w3schools%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette4Fg"
		},

		["stackoverflow%.com"] = {
			priority = -9999,

			icon = "󰓌 ",
			hl = "MarkviewPalette2Fg"
		},

		["reddit%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["github%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["gitlab%.com"] = {
			priority = -9999,

			icon = "󰮠 ",
			hl = "MarkviewPalette2Fg"
		},

		["dev%.to"] = {
			priority = -9999,

			icon = "󱁴 ",
			hl = "MarkviewPalette0Fg"
		},

		["codepen%.io"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["replit%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["jsfiddle%.net"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette5Fg"
		},

		["npmjs%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["pypi%.org"] = {
			priority = -9999,

			icon = "󰆦 ",
			hl = "MarkviewPalette0Fg"
		},

		["mvnrepository%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette1Fg"
		},

		["medium%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["linkedin%.com"] = {
			priority = -9999,

			icon = "󰌻 ",
			hl = "MarkviewPalette5Fg"
		},

		["news%.ycombinator%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},
	},

	images = {
		enable = true,

		default = {
			icon = "󰥶 ",
			hl = "MarkviewImage",
		},

		["%.svg$"] = { icon = "󰜡 " },
		["%.png$"] = { icon = "󰸭 " },
		["%.jpg$"] = { icon = "󰈥 " },
		["%.gif$"] = { icon = "󰵸 " },
		["%.pdf$"] = { icon = " " }
	},

	inline_codes = {
		enable = true,
		hl = "MarkviewInlineCode",

		padding_left = " ",
		padding_right = " "
	},

	internal_links = {
		enable = true,

		default = {
			icon = " ",
			hl = "MarkviewPalette7Fg",
		},
	},

	uri_autolinks = {
		enable = true,

		default = {
			icon = " ",
			hl = "MarkviewEmail"
		},

		["github%.com/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/tree/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>/tree/<branch>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/commits/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>/commits/<branch>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/releases$"] = {
			--- github.com/<user>/<repo>/releases

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/tags$"] = {
			--- github.com/<user>/<repo>/tags

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/issues$"] = {
			--- github.com/<user>/<repo>/issues

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/pulls$"] = {
			--- github.com/<user>/<repo>/pulls

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/wiki$"] = {
			--- github.com/<user>/<repo>/wiki

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["developer%.mozilla%.org"] = {
			priority = -9999,

			icon = "󰖟 ",
			hl = "MarkviewPalette5Fg"
		},

		["w3schools%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette4Fg"
		},

		["stackoverflow%.com"] = {
			priority = -9999,

			icon = "󰓌 ",
			hl = "MarkviewPalette2Fg"
		},

		["reddit%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["github%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["gitlab%.com"] = {
			priority = -9999,

			icon = "󰮠 ",
			hl = "MarkviewPalette2Fg"
		},

		["dev%.to"] = {
			priority = -9999,

			icon = "󱁴 ",
			hl = "MarkviewPalette0Fg"
		},

		["codepen%.io"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["replit%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["jsfiddle%.net"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette5Fg"
		},

		["npmjs%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["pypi%.org"] = {
			priority = -9999,

			icon = "󰆦 ",
			hl = "MarkviewPalette0Fg"
		},

		["mvnrepository%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette1Fg"
		},

		["medium%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["linkedin%.com"] = {
			priority = -9999,

			icon = "󰌻 ",
			hl = "MarkviewPalette5Fg"
		},

		["news%.ycombinator%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},
	},

	tags = {
		enable = true,

		default = {
			padding_left = " ",
			padding_right = " ",

			hl = "MarkviewPalette7"
		}
	},
};

```

## lua/markview/config/typst.lua

```lua
---@type markview.config.typst
return {
	enable = true,

	code_blocks = {
		enable = true,

		hl = "MarkviewCode",

		min_width = 60,
		pad_amount = 3,
		pad_char = " ",

		style = "block",

		text = "󰣖 Code",
		text_direction = "right",
		text_hl = "MarkviewIcon5"
	},

	code_spans = {
		enable = true,

		padding_left = " ",
		padding_right = " ",

		hl = "MarkviewCode"
	},

	escapes = {
		enable = true
	},

	headings = {
		enable = true,
		shift_width = 1,

		heading_1 = {
			style = "icon",
			sign = "󰌕 ", sign_hl = "MarkviewHeading1Sign",

			icon = "󰼏  ", hl = "MarkviewHeading1",
		},
		heading_2 = {
			style = "icon",
			sign = "󰌖 ", sign_hl = "MarkviewHeading2Sign",

			icon = "󰎨  ", hl = "MarkviewHeading2",
		},
		heading_3 = {
			style = "icon",

			icon = "󰼑  ", hl = "MarkviewHeading3",
		},
		heading_4 = {
			style = "icon",

			icon = "󰎲  ", hl = "MarkviewHeading4",
		},
		heading_5 = {
			style = "icon",

			icon = "󰼓  ", hl = "MarkviewHeading5",
		},
		heading_6 = {
			style = "icon",

			icon = "󰎴  ", hl = "MarkviewHeading6",
		},

		org_indent = false,
		org_shift_char = " ",
		org_shift_width = 1,
	},

	labels = {
		enable = true,

		default = {
			hl = "MarkviewInlineCode",
			padding_left = " ",
			icon = " ",
			padding_right = " "
		}
	},

	list_items = {
		enable = true,

		indent_size = function (buffer)
			if type(buffer) ~= "number" then
				return vim.bo.shiftwidth or 4;
			end

			--- Use 'shiftwidth' value.
			return vim.bo[buffer].shiftwidth or 4;
		end,
		shift_width = 4,

		marker_minus = {
			add_padding = true,

			text = "●",
			hl = "MarkviewListItemMinus"
		},

		marker_plus = {
			add_padding = true,

			text = "%d)",
			hl = "MarkviewListItemPlus"
		},

		marker_dot = {
			add_padding = true,

			text = "%d.",
			hl = "MarkviewListItemStar"
		}
	},

	math_blocks = {
		enable = true,

		text = " 󰪚 Math ",
		pad_amount = 3,
		pad_char = " ",

		hl = "MarkviewCode",
		text_hl = "MarkviewCodeInfo"
	},

	math_spans = {
		enable = true,

		padding_left = " ",
		padding_right = " ",

		hl = "MarkviewInlineCode"
	},

	raw_blocks = {
		enable = true,

		style = "block",
		label_direction = "right",

		sign = true,

		min_width = 60,
		pad_amount = 3,
		pad_char = " ",

		border_hl = "MarkviewCode",

		default = {
			block_hl = "MarkviewCode",
			pad_hl = "MarkviewCode"
		},

		["diff"] = {
			block_hl = function (_, line)
				if line:match("^%+") then
					return "MarkviewPalette4";
				elseif line:match("^%-") then
					return "MarkviewPalette1";
				else
					return "MarkviewCode";
				end
			end,
			pad_hl = "MarkviewCode"
		}
	},

	raw_spans = {
		enable = true,

		padding_left = " ",
		padding_right = " ",

		hl = "MarkviewInlineCode"
	},

	reference_links = {
		enable = true,

		default = {
			icon = " ",
			hl = "MarkviewHyperlink"
		},
	},

	subscripts = {
		enable = true,

		hl = "MarkviewSubscript"
	},

	superscripts = {
		enable = true,

		hl = "MarkviewSuperscript"
	},

	symbols = {
		enable = true,

		hl = "Special"
	},

	terms = {
		enable = true,

		default = {
			text = " ",
			hl = "MarkviewPalette6Fg"
		},
	},

	url_links = {
		enable = true,

		default = {
			icon = " ",
			hl = "MarkviewEmail"
		},

		["github%.com/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/tree/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>/tree/<branch>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+/commits/[%a%d%-%_%.]+%/?$"] = {
			--- github.com/<user>/<repo>/commits/<branch>

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/releases$"] = {
			--- github.com/<user>/<repo>/releases

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/tags$"] = {
			--- github.com/<user>/<repo>/tags

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/issues$"] = {
			--- github.com/<user>/<repo>/issues

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},
		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/pulls$"] = {
			--- github.com/<user>/<repo>/pulls

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["github%.com/[%a%d%-%_%.]+/[%a%d%-%_%.]+%/wiki$"] = {
			--- github.com/<user>/<repo>/wiki

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["developer%.mozilla%.org"] = {
			priority = -9999,

			icon = "󰖟 ",
			hl = "MarkviewPalette5Fg"
		},

		["w3schools%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette4Fg"
		},

		["stackoverflow%.com"] = {
			priority = -9999,

			icon = "󰓌 ",
			hl = "MarkviewPalette2Fg"
		},

		["reddit%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["github%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["gitlab%.com"] = {
			priority = -9999,

			icon = "󰮠 ",
			hl = "MarkviewPalette2Fg"
		},

		["dev%.to"] = {
			priority = -9999,

			icon = "󱁴 ",
			hl = "MarkviewPalette0Fg"
		},

		["codepen%.io"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["replit%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},

		["jsfiddle%.net"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette5Fg"
		},

		["npmjs%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette0Fg"
		},

		["pypi%.org"] = {
			priority = -9999,

			icon = "󰆦 ",
			hl = "MarkviewPalette0Fg"
		},

		["mvnrepository%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette1Fg"
		},

		["medium%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette6Fg"
		},

		["linkedin%.com"] = {
			priority = -9999,

			icon = "󰌻 ",
			hl = "MarkviewPalette5Fg"
		},

		["news%.ycombinator%.com"] = {
			priority = -9999,

			icon = " ",
			hl = "MarkviewPalette2Fg"
		},
	}
};

```

## lua/markview/config/yaml.lua

```lua
return {
	enable = true,

	properties = {
		enable = true,

		data_types = {
			["text"] = {
				text = "󰗊 ", hl = "MarkviewIcon4"
			},
			["list"] = {
				text = "󰝖 ", hl = "MarkviewIcon5"
			},
			["number"] = {
				text = " ", hl = "MarkviewIcon6"
			},
			["checkbox"] = {
				---@diagnostic disable
				text = function (_, item)
					return item.value == "true" and "󰄲 " or "󰄱 "
				end,
				---@diagnostic enable
				hl = "MarkviewIcon6"
			},
			["date"] = {
				text = "󰃭 ", hl = "MarkviewIcon2"
			},
			["date_&_time"] = {
				text = "󰥔 ", hl = "MarkviewIcon3"
			}
		},

		default = {
			use_types = true,

			border_top = nil,
			border_middle = nil,
			border_bottom = nil,

			border_hl = nil,
		},

		["^tags$"] = {
			use_types = false,

			text = "󰓹 ",
			hl = "MarkviewIcon0"
		},
		["^aliases$"] = {
			match_string = "^aliases$",
			use_types = false,

			text = "󱞫 ",
			hl = "MarkviewIcon2"
		},
		["^cssclasses$"] = {
			match_string = "^cssclasses$",
			use_types = false,

			text = " ",
			hl = "MarkviewIcon3"
		},


		["^publish$"] = {
			match_string = "^publish$",
			use_types = false,

			text = "󰅧 ",
			hl = "MarkviewIcon5"
		},
		["^permalink$"] = {
			match_string = "^permalink$",
			use_types = false,

			text = " ",
			hl = "MarkviewIcon2"
		},
		["^description$"] = {
			match_string = "^description$",
			use_types = false,

			text = "󰋼 ",
			hl = "MarkviewIcon0"
		},
		["^image$"] = {
			match_string = "^image$",
			use_types = false,

			text = "󰋫 ",
			hl = "MarkviewIcon4"
		},
		["^cover$"] = {
			match_string = "^cover$",
			use_types = false,

			text = "󰹉 ",
			hl = "MarkviewIcon2"
		}
	}
};

```

## lua/markview/spec.lua

```lua
--- Configuration specification file
--- for `markview.nvim`.
---
--- It has the following tasks,
---    • Check for issues with config
local spec = {};

---@type markview.config
spec.default = {
	experimental = {
		fancy_comments = false,

		date_formats = {
			"^%d%d%d%d%-%d%d%-%d%d$",      --- YYYY-MM-DD
			"^%d%d%-%d%d%-%d%d%d%d$",      --- DD-MM-YYYY, MM-DD-YYYY
			"^%d%d%-%d%d%-%d%d$",          --- DD-MM-YY, MM-DD-YY, YY-MM-DD

			"^%d%d%d%d%/%d%d%/%d%d$",      --- YYYY/MM/DD
			"^%d%d%/%d%d%/%d%d%d%d$",      --- DD/MM/YYYY, MM/DD/YYYY

			"^%d%d%d%d%.%d%d%.%d%d$",      --- YYYY.MM.DD
			"^%d%d%.%d%d%.%d%d%d%d$",      --- DD.MM.YYYY, MM.DD.YYYY

			"^%d%d %a+ %d%d%d%d$",         --- DD Month YYYY
			"^%a+ %d%d %d%d%d%d$",         --- Month DD, YYYY
			"^%d%d%d%d %a+ %d%d$",         --- YYYY Month DD

			"^%a+%, %a+ %d%d%, %d%d%d%d$", --- Day, Month DD, YYYY
		},

		date_time_formats = {
			"^%a%a%a %a%a%a %d%d %d%d%:%d%d%:%d%d ... %d%d%d%d$", --- UNIX date time
			"^%d%d%d%d%-%d%d%-%d%dT%d%d%:%d%d%:%d%dZ$",           --- ISO 8601
		},

		prefer_nvim = false,
		file_open_command = "tabnew",

		list_empty_line_tolerance = 3,

		read_chunk_size = 1024,

		linewise_ignore_org_indent = false
	};

	highlight_groups = {},

	preview = {
		enable = true,
		enable_hybrid_mode = true,

		callbacks = {
			on_attach = function (_, wins)
				--- Initial state for attached buffers.
				---@type string
				local attach_state = spec.get({ "preview", "enable" }, { fallback = true, ignore_enable = true });

				if attach_state == false then
					--- Attached buffers will not have their previews
					--- enabled.
					--- So, don't set options.
					return;
				end

				for _, win in ipairs(wins) do
					--- Preferred conceal level should
					--- be 3.
					vim.wo[win].conceallevel = 3;
				end
			end,

			on_detach = function (_, wins)
				for _, win in ipairs(wins) do
					--- Only set `conceallevel`.
					--- `concealcursor` will be
					--- set via `on_hybrid_disable`.
					vim.wo[win].conceallevel = 0;
				end
			end,

			on_enable = function (_, wins)
				--- Initial state for attached buffers.
				---@type string
				local attach_state = spec.get({ "preview", "enable" }, { fallback = true, ignore_enable = true });

				if attach_state == false then
					-- If the window's aren't initially
					-- attached, we need to set the 
					-- 'concealcursor' too.

					---@type string[]
					local preview_modes = spec.get({ "preview", "modes" }, { fallback = {}, ignore_enable = true });
					---@type string[]
					local hybrid_modes = spec.get({ "preview", "hybrid_modes" }, { fallback = {}, ignore_enable = true });

					local concealcursor = "";

					for _, mode in ipairs(preview_modes) do
						if vim.list_contains(hybrid_modes, mode) == false and vim.list_contains({ "n", "v", "i", "c" }, mode) then
							concealcursor = concealcursor .. mode;
						end
					end

					for _, win in ipairs(wins) do
						vim.wo[win].conceallevel = 3;
						vim.wo[win].concealcursor = concealcursor;
					end
				else
					for _, win in ipairs(wins) do
						vim.wo[win].conceallevel = 3;
					end
				end
			end,

			on_disable = function (_, wins)
				for _, win in ipairs(wins) do
					vim.wo[win].conceallevel = 0;
				end
			end,

			on_hybrid_enable = function (_, wins)
				---@type string[]
				local preview_modes = spec.get({ "preview", "modes" }, { fallback = {}, ignore_enable = true });
				---@type string[]
				local hybrid_modes = spec.get({ "preview", "hybrid_modes" }, { fallback = {}, ignore_enable = true });

				local concealcursor = "";

				for _, mode in ipairs(preview_modes) do
					if vim.list_contains(hybrid_modes, mode) == false and vim.list_contains({ "n", "v", "i", "c" }, mode) then
						concealcursor = concealcursor .. mode;
					end
				end

				for _, win in ipairs(wins) do
					vim.wo[win].concealcursor = concealcursor;
				end
			end,

			on_hybrid_disable = function (_, wins)
				---@type string[]
				local preview_modes = spec.get({ "preview", "modes" }, { fallback = {}, ignore_enable = true });
				local concealcursor = "";

				for _, mode in ipairs(preview_modes) do
					if vim.list_contains({ "n", "v", "i", "c" }, mode) then
						concealcursor = concealcursor .. mode;
					end
				end

				for _, win in ipairs(wins) do
					vim.wo[win].concealcursor = concealcursor;
				end
			end,

			on_mode_change = function (_, wins, current_mode)
				---@type string[]
				local preview_modes = spec.get({ "preview", "modes" }, { fallback = {}, ignore_enable = true });
				---@type string[]
				local hybrid_modes = spec.get({ "preview", "hybrid_modes" }, { fallback = {}, ignore_enable = true });

				local concealcursor = "";

				for _, mode in ipairs(preview_modes) do
					if vim.list_contains(hybrid_modes, mode) == false and vim.list_contains({ "n", "v", "i", "c" }, mode) then
						concealcursor = concealcursor .. mode;
					end
				end

				for _, win in ipairs(wins) do
					if vim.list_contains(preview_modes, current_mode) then
						vim.wo[win].conceallevel = 3;
						vim.wo[win].concealcursor = concealcursor;
					else
						vim.wo[win].conceallevel = 0;
						vim.wo[win].concealcursor = "";
					end
				end
			end,

			on_splitview_open = function (_, _, win)
				vim.wo[win].conceallevel = 3;
				vim.wo[win].concealcursor = "n";
			end
		},

		map_gx = true,

		debounce = 150,
		icon_provider = "internal",

		filetypes = { "markdown", "quarto", "rmd", "typst", "asciidoc", },
		ignore_buftypes = { "nofile" },
		condition = function (buffer)
			local is_enabled = spec.get({ "experimental", "fancy_comments" }, {
				fallback = false,
			});

			if not is_enabled then
				return false;
			end

			local success, parser = pcall(vim.treesitter.get_parser, buffer);
			return success and parser ~= nil;
		end,

		raw_previews = {},

		modes = { "n", "no", "c" },
		hybrid_modes = {},

		linewise_hybrid_mode = false,
		max_buf_lines = 1000,

		draw_range = { 1 * vim.o.lines, 1 * vim.o.lines },
		edit_range = { 0, 0 },

		splitview_winopts = {
			split = "right"
		},
	},

	renderers = {},
};

---@type string[] Properties that should be sourced *externally*.
spec.__external_config = {
	"asciidoc",
	"asciidoc_inline",
	"comment",
	"html",
	"markdown",
	"markdown_inline",
	"latex",
	"typst",
	"yaml",
};

spec.config = vim.deepcopy(spec.default);
spec.tmp_config = nil;

---@param config markview.config?
spec.tmp_setup = function (config)
	spec.tmp_config = config;
end

spec.tmp_reset = function ()
	spec.tmp_config = nil;
end

--- Setup function for markview.
---@param config markview.config?
spec.setup = function (config)
	if package.loaded["markview.renderers.markdown.tostring"] then
		-- NOTE: Only update the cache used by `tostring()` when config is updated.
		require("markview.renderers.markdown.tostring").update_cache();
	end

	spec.config = vim.tbl_deep_extend("force", spec.config, config or {});
end

--- Function to retrieve configuration options
--- from a config table.
---@param keys ( string | integer )[]
---@param opts markview.spec.get_opts
---@return any
spec.get = function (keys, opts)
	--- In case the values are correctly provided..
	keys = keys or {};
	opts = opts or {};

	--- Turns a dynamic value into
	--- a static value.
	---@param val any | fun(...): any
	---@param args any[]?
	---@return any
	local function to_static(val, args)
		if type(val) ~= "function" then
			return val;
		end

		local ok, res = pcall(val, unpack(args or {}));
		return ok and res or nil;
	end

	---@param index integer | string
	---@return any
	local function get_arg(index)
		if type(opts.args) ~= "table" then
			return {};
		elseif opts.args.__is_arg_list == true then
			return opts.args[index];
		else
			return opts.args;
		end
	end

	--- Temporarily store the value.
	---
	--- Use `deepcopy()` as we may need to
	--- modify this value.
	---@type any
	local val;

	if type(opts.source) == "table" or type(opts.source) == "function" then
		-- Custom config source provided.
		val = opts.source;
	elseif spec.tmp_config then
		if vim.list_contains(spec.__external_config, keys[1]) then
			local could_load, loaded = pcall(require, "markview.config." .. keys[1]);

			if
				could_load and type(loaded) == "table" and
				#vim.tbl_keys(loaded) ~= #vim.tbl_keys(spec.tmp_config[keys[1]] or {})
			then
				spec.tmp_config[keys[1]] = vim.tbl_deep_extend(
					"keep",
					spec.tmp_config[keys[1]] or {},
					loaded
				);
			end
		end

		val = spec.tmp_config;
	elseif spec.config then
		if vim.list_contains(spec.__external_config, keys[1]) then
			local could_load, loaded = pcall(require, "markview.config." .. keys[1]);

			if
				could_load and type(loaded) == "table" and
				#vim.tbl_keys(loaded) ~= #vim.tbl_keys(spec.config[keys[1]] or {})
			then
				spec.config[keys[1]] = vim.tbl_deep_extend(
					"keep",
					spec.config[keys[1]] or {},
					loaded
				);
			end
		end

		val = spec.config;
	else
		val = {};
	end

	--- Turn the main value into a static value.
	--- [ In case a function was provided as the source. ]
	val = to_static(val, get_arg("init"));

	if type(val) ~= "table" then
		--- The source isn't a table.
		return opts.fallback;
	end

	for k, key in ipairs(keys) do
		if k ~= #keys then
			val = to_static(val[key], val.args);

			if type(val) ~= "table" then
				return opts.fallback;
			elseif opts.ignore_enable ~= true and val.enable == false then
				return opts.fallback;
			end
		else
			--- Do not evaluate the final
			--- value.
			---
			--- It should be evaluated using
			--- `eval_args`.
			val = val[key];
		end
	end

	if vim.islist(opts.eval_args) == true and type(val) == "table" then
		local _e = {};
		local eval = opts.eval or vim.tbl_keys(val);
		local ignore = opts.eval_ignore or {};

		for k, v in pairs(val) do
			if type(v) ~= "function" then
				--- A silly attempt at reducing
				--- wasted time due to extra
				--- logic.
				_e[k] = v;
			elseif vim.list_contains(ignore, k) == false then
				if vim.list_contains(eval, k) then
					_e[k] = to_static(v, opts.eval_args);
				else
					_e[k] = v;
				end
			else
				_e[k] = v;
			end
		end

		val = _e;
	elseif vim.islist(opts.eval_args) == true and type(val) == "function" then
		val = to_static(val, opts.eval_args);
	end

	if val == nil and opts.fallback then
		return opts.fallback;
	elseif type(val) == "table" and ( opts.ignore_enable ~= true and val.enable == false ) then
		return opts.fallback;
	else
		return val;
	end
end

return spec;
-- vim:foldmethod=indent

```

## LICENSE

```text
                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.

   END OF TERMS AND CONDITIONS

   APPENDIX: How to apply the Apache License to your work.

      To apply the Apache License to your work, attach the following
      boilerplate notice, with the fields enclosed by brackets "[]"
      replaced with your own identifying information. (Don't include
      the brackets!)  The text should be enclosed in the appropriate
      comment syntax for the file format. We also recommend that a
      file or class name and description of purpose be included on the
      same "printed page" as the copyright notice for easier
      identification within third-party archives.

   Copyright [yyyy] [name of copyright owner]

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

```
