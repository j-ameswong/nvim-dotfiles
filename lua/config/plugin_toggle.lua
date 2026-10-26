-- :PluginToggle lists every spec in lua/plugins/ and flips its `enabled` flag.
-- It warns when disabling a plugin breaks something that still uses it, and
-- when an enabled plugin needs one that is switched off. Toggles stay pending
-- until written with `w`; restart Neovim to apply them.
--
-- "Uses" comes from a spec's `dependencies`, plus a scan of this config for
-- require("module"), autoload#calls and :Commands that belong to a plugin's
-- installed checkout. lazy.nvim drops a disabled plugin even when another spec
-- lists it as a dependency, so the dependent then fails at load.

local config_dir = vim.fn.stdpath("config")
local this_file = vim.fs.normalize(debug.getinfo(1, "S").source:sub(2))
local ns = vim.api.nvim_create_namespace("plugin_toggle")
local detail_height = 10

local function lazy_root()
	local ok, Config = pcall(require, "lazy.core.config")
	return ok and Config.options.root or vim.fn.stdpath("data") .. "/lazy"
end

local function plugin_name(ref)
	return (ref:gsub("%.git$", ""):match("[^/]+$"))
end

local function list(value)
	if value == nil then
		return {}
	end
	return type(value) == "table" and value or { value }
end

local function find_files(dir, extensions)
	if not vim.uv.fs_stat(dir) then
		return {}
	end
	local files = vim.fs.find(function(name)
		return extensions[name:match("%.(%w+)$")] == true
	end, { path = dir, type = "file", limit = math.huge })
	table.sort(files)
	return files
end

-- The `"owner/repo",` line of a spec, and the value of the `enabled = ...,`
-- line directly under it. That pair is what gets rewritten.
local function locate(lines, repo)
	local name_pattern = "^(%s*)[\"']" .. vim.pesc(repo) .. "[\"'],%s*$"
	for i, line in ipairs(lines) do
		local indent = line:match(name_pattern)
		if indent then
			return i, indent, (lines[i + 1] or ""):match("^%s*enabled%s*=%s*(%a+)%s*,")
		end
	end
end

local function is_bool(value)
	return value == "true" or value == "false"
end

local function load_specs()
	local specs = {}
	for _, path in ipairs(find_files(config_dir .. "/lua/plugins", { lua = true })) do
		local ok, ret = pcall(dofile, path)
		if not ok then
			vim.notify("PluginToggle: " .. ret, vim.log.levels.WARN)
		elseif type(ret) == "table" then
			local lines = vim.fn.readfile(path, "b")
			local located = {}
			for _, spec in ipairs(type(ret[1]) == "string" and { ret } or ret) do
				if type(spec) == "table" and type(spec[1]) == "string" then
					local line, indent, value = locate(lines, spec[1])
					local deps = {}
					for _, dep in ipairs(list(spec.dependencies)) do
						local ref = type(dep) == "table" and (dep.name or dep[1]) or dep
						if type(ref) == "string" then
							table.insert(deps, plugin_name(ref))
						end
					end
					local entry = {
						name = spec.name or plugin_name(spec[1]),
						repo = spec[1],
						path = path,
						rel = path:sub(#config_dir + 2),
						group = vim.fs.basename(vim.fs.dirname(path)),
						line = line,
						-- a missing flag is inserted on write; anything else (a function,
						-- an inline flag) is left alone
						editable = line ~= nil and (is_bool(value) or (value == nil and spec.enabled == nil)),
						enabled = spec.enabled ~= false,
						deps = deps,
						cmd = list(spec.cmd),
						main = spec.main,
					}
					entry.pending = entry.enabled
					table.insert(specs, entry)
					if line then
						table.insert(located, entry)
					end
				end
			end
			-- each spec owns the lines from its name to the next spec in the file,
			-- the first one also owns the file's preamble
			table.sort(located, function(a, b)
				return a.line < b.line
			end)
			for i, entry in ipairs(located) do
				entry.first = i == 1 and 1 or entry.line
				entry.last = located[i + 1] and located[i + 1].line - 1 or #lines
			end
		end
	end
	table.sort(specs, function(a, b)
		if a.group ~= b.group then
			return a.group < b.group
		end
		return a.name:lower() < b.name:lower()
	end)
	return specs
end

-- Map lua modules, autoload prefixes and user commands to the plugin that provides them.
local function index_identifiers(specs)
	local root = lazy_root()
	local index = { module = {}, autoload = {}, command = {} }
	local dirs = {}
	for _, spec in ipairs(specs) do
		for _, command in ipairs(spec.cmd) do
			index.command[command] = spec.name
		end
		if spec.main then
			index.module[spec.main] = spec.name
		end
		local dir = root .. "/" .. spec.name
		spec.installed = vim.uv.fs_stat(dir) ~= nil
		if spec.installed then
			table.insert(dirs, dir)
			for _, file in ipairs(find_files(dir .. "/lua", { lua = true })) do
				local module = file:sub(#dir + 6, -5):gsub("/init$", ""):gsub("/", ".")
				index.module[module] = spec.name
			end
			for _, file in ipairs(find_files(dir .. "/autoload", { vim = true })) do
				local prefix = file:sub(#dir + 11, -5):gsub("/", "#")
				index.autoload[prefix] = spec.name
			end
		end
	end

	if #dirs > 0 and vim.fn.executable("rg") == 1 then
		local cmd = {
			"rg", "--no-heading", "--no-line-number", "--with-filename", "--only-matching",
			"--replace", "$1", "--glob", "*.{lua,vim}",
			"-e", [=[\w*command\(\s*["']([A-Z]\w+)["']]=],
			"-e", [=[^\s*com(?:mand)?!?\s+(?:-\S+\s+)*([A-Z]\w+)]=],
		}
		vim.list_extend(cmd, dirs)
		local out = vim.system(cmd, { text = true }):wait().stdout or ""
		for line in out:gmatch("[^\n]+") do
			local file, command = line:match("^(.*):(%u[%w_]*)$")
			local name = file and file:sub(#root + 2):match("^[^/]+")
			if name and not index.command[command] then
				index.command[command] = name
			end
		end
	end
	return index
end

local command_patterns = {
	"<[cC][mM][dD]>%s*(%u[%w_]*)",
	"vim%.cmd%.(%u[%w_]*)",
	"vim%.cmd%s*%(?%s*[\"'%[=]+%s*(%u[%w_]*)",
	"[%s\"'>]:(%u[%w_]*)",
	"^:(%u[%w_]*)",
}

-- { kind, identifier, how it appears } for each possible plugin reference on a line
local function references(line)
	local found = {}
	for module in line:gmatch("require%s*%(?%s*[\"']([%w_%.%-]+)[\"']") do
		table.insert(found, { "module", module, ('require("%s")'):format(module) })
	end
	for prefix, fn in line:gmatch("([%w_#]+)#([%w_]+)") do
		table.insert(found, { "autoload", prefix, prefix .. "#" .. fn })
	end
	for _, pattern in ipairs(command_patterns) do
		for command in line:gmatch(pattern) do
			table.insert(found, { "command", command, ":" .. command })
		end
	end
	return found
end

-- Edges point from a user (a plugin name, or nil for plain config files that are
-- always loaded) to the plugin it needs.
local function build_edges(specs, by_name, index)
	local edges, seen = {}, {}
	local function add(from, to, why, where)
		if from == to or not by_name[to] then
			return
		end
		local key = table.concat({ from or "", to, why, where }, "\0")
		if not seen[key] then
			seen[key] = true
			table.insert(edges, { from = from, to = to, why = why, where = where })
		end
	end

	local ok, Config = pcall(require, "lazy.core.config")
	for _, spec in ipairs(specs) do
		local deps = vim.list_extend({}, spec.deps)
		-- lazy also merges dependencies a plugin declares in its own lazy.lua or rockspec
		local resolved = ok and Config.spec and (Config.plugins[spec.name] or Config.spec.disabled[spec.name])
		vim.list_extend(deps, resolved and resolved.dependencies or {})
		for _, dep in ipairs(deps) do
			add(spec.name, dep, "dependency", spec.rel .. ":" .. (spec.line or 1))
		end
	end

	local owners = {}
	for _, spec in ipairs(specs) do
		if spec.first then
			owners[spec.path] = owners[spec.path] or {}
			table.insert(owners[spec.path], spec)
		end
	end
	local files = { config_dir .. "/init.lua" }
	for _, dir in ipairs({ "lua", "ftplugin", "after", "plugin" }) do
		vim.list_extend(files, find_files(config_dir .. "/" .. dir, { lua = true, vim = true }))
	end
	for _, file in ipairs(files) do
		if vim.fs.normalize(file) ~= this_file then
			local rel = file:sub(#config_dir + 2)
			for lnum, line in ipairs(vim.fn.readfile(file)) do
				if not line:match("^%s*%-%-") and not line:match('^%s*"') then
					local owner
					for _, spec in ipairs(owners[file] or {}) do
						if lnum >= spec.first and lnum <= spec.last then
							owner = spec.name
						end
					end
					for _, ref in ipairs(references(line)) do
						add(owner, index[ref[1]][ref[2]], ref[3], rel .. ":" .. lnum)
					end
				end
			end
		end
	end
	return edges
end

local function scan(state)
	state.specs = load_specs()
	state.by_name = {}
	for _, spec in ipairs(state.specs) do
		state.by_name[spec.name] = spec
	end
	state.edges = build_edges(state.specs, state.by_name, index_identifiers(state.specs))
end

local function is_active(state, name)
	return name == nil or state.by_name[name].pending
end

local function source_label(edge)
	return edge.from or (edge.where:match("[^/]+$"):gsub(":%d+$", ""))
end

-- Disabled plugins that `spec` uses.
local function needs(state, spec)
	return vim.tbl_filter(function(edge)
		return edge.from == spec.name and not state.by_name[edge.to].pending
	end, state.edges)
end

-- Loaded code that uses `spec`.
local function breaks(state, spec)
	return vim.tbl_filter(function(edge)
		return edge.to == spec.name and is_active(state, edge.from)
	end, state.edges)
end

local function unique(edges, label)
	local names, seen = {}, {}
	for _, edge in ipairs(edges) do
		local name = label(edge)
		if not seen[name] then
			seen[name] = true
			table.insert(names, name)
		end
	end
	return names
end

-- Build a line from { text, highlight } chunks.
local function compose(chunks)
	local text, highlights = "", {}
	for _, chunk in ipairs(chunks) do
		if chunk[2] then
			table.insert(highlights, { #text, #text + #chunk[1], chunk[2] })
		end
		text = text .. chunk[1]
	end
	return { text = text, highlights = highlights }
end

local function set_lines(buf, rows)
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.tbl_map(function(row)
		return row.text
	end, rows))
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for i, row in ipairs(rows) do
		for _, hl in ipairs(row.highlights) do
			vim.api.nvim_buf_set_extmark(buf, ns, i - 1, hl[1], { end_col = hl[2], hl_group = hl[3] })
		end
	end
	vim.bo[buf].modifiable = false
end

local function render_list(state)
	local rows, group = {}, nil
	state.row_spec = {}
	for _, spec in ipairs(state.specs) do
		if spec.group ~= group then
			if group then
				table.insert(rows, compose({}))
			end
			group = spec.group
			table.insert(rows, compose({ { " " .. group, "Title" } }))
		end

		local icon, warning = { "●", "DiagnosticOk" }, { "" }
		if not spec.editable then
			icon, warning = { "?", "DiagnosticHint" }, { "no `enabled = true,` under its name", "Comment" }
		elseif not spec.pending then
			icon = { "○", "Comment" }
			local broken = breaks(state, spec)
			if #broken > 0 then
				warning = { "✗ breaks " .. table.concat(unique(broken, source_label), ", "), "DiagnosticError" }
			end
		else
			local missing = needs(state, spec)
			if #missing > 0 then
				warning = { "⚠ needs " .. table.concat(unique(missing, function(e) return e.to end), ", "), "DiagnosticWarn" }
			end
		end

		table.insert(rows, compose({
			{ "  " },
			icon,
			{ " " },
			{ ("%-28s"):format(spec.name), not spec.pending and "Comment" or nil },
			{ spec.pending ~= spec.enabled and "* " or "  ", "DiagnosticInfo" },
			warning,
		}))
		state.row_spec[#rows] = spec
	end
	set_lines(state.list_buf, rows)
end

local function render_detail(state)
	local spec = state.row_spec[vim.api.nvim_win_get_cursor(state.list_win)[1]]
	if not spec then
		return set_lines(state.detail_buf, {})
	end

	local status = spec.pending and "enabled" or "disabled"
	if spec.pending ~= spec.enabled then
		status = status .. " (unsaved)"
	end
	local rows = {
		compose({ { " " .. spec.name, "Title" }, { "  " .. spec.rel .. ":" .. (spec.line or "?"), "Comment" }, { "  " .. status } }),
	}

	-- one row per counterpart: the first place it's referenced, plus how many more
	local function section(title, edges, counterpart, problem)
		table.insert(rows, compose({ { " " .. title, "Label" } }))
		if #edges == 0 then
			table.insert(rows, compose({ { "   nothing", "Comment" } }))
		end
		local grouped, order = {}, {}
		for _, edge in ipairs(edges) do
			local name = counterpart(edge)
			if not grouped[name] then
				grouped[name] = {}
				table.insert(order, name)
			end
			table.insert(grouped[name], edge)
		end
		for _, name in ipairs(order) do
			local first = grouped[name][1]
			local more = #grouped[name] > 1 and (" +%d more"):format(#grouped[name] - 1) or ""
			local on = problem(first) == nil
			table.insert(rows, compose({
				{ "   " },
				problem(first) or { on and "●" or "○", on and "DiagnosticOk" or "Comment" },
				{ (" %-26s"):format(name) },
				{ first.why .. "  " },
				{ first.where .. more, "Comment" },
			}))
		end
	end

	section("Uses", vim.tbl_filter(function(e) return e.from == spec.name end, state.edges), function(e)
		return e.to
	end, function(e)
		local target = state.by_name[e.to].pending
		if spec.pending and not target then
			return { "⚠", "DiagnosticWarn" }
		end
		return not target and { "○", "Comment" } or nil
	end)
	section("Used by", vim.tbl_filter(function(e) return e.to == spec.name end, state.edges), source_label, function(e)
		local active = is_active(state, e.from)
		if active and not spec.pending then
			return { "✗", "DiagnosticError" }
		end
		return not active and { "○", "Comment" } or nil
	end)
	if not spec.installed then
		table.insert(rows, compose({ { " not installed: only declared dependencies and cmd are checked", "Comment" } }))
	end
	set_lines(state.detail_buf, rows)
end

local function render(state)
	render_list(state)
	render_detail(state)
end

local function changed_specs(state)
	return vim.tbl_filter(function(spec)
		return spec.pending ~= spec.enabled
	end, state.specs)
end

local function write(state)
	local changed = changed_specs(state)
	if #changed == 0 then
		return vim.notify("PluginToggle: nothing to write")
	end
	local by_path = {}
	for _, spec in ipairs(changed) do
		by_path[spec.path] = by_path[spec.path] or {}
		table.insert(by_path[spec.path], spec)
	end
	local written = 0
	for path, specs in pairs(by_path) do
		local lines = vim.fn.readfile(path, "b")
		for _, spec in ipairs(specs) do
			-- re-locate on the file as it is now, in case it changed since opening
			local line, indent, value = locate(lines, spec.repo)
			local flag = "enabled = " .. tostring(spec.pending)
			if line and is_bool(value) then
				lines[line + 1] = lines[line + 1]:gsub("enabled%s*=%s*%a+", flag, 1)
				written = written + 1
			elseif line and value == nil then
				table.insert(lines, line + 1, indent .. flag .. ",")
				written = written + 1
			else
				vim.notify("PluginToggle: couldn't find the enabled flag for " .. spec.name, vim.log.levels.ERROR)
			end
		end
		vim.fn.writefile(lines, path, "b")
	end
	vim.notify(("PluginToggle: wrote %d change(s), restart Neovim to apply"):format(written))
	scan(state)
	render(state)
end

local function toggle(state)
	local spec = state.row_spec[vim.api.nvim_win_get_cursor(state.list_win)[1]]
	if not spec then
		return
	end
	if not spec.editable then
		return vim.notify(
			("PluginToggle: add `enabled = true,` on the line after %q in %s"):format(spec.repo, spec.rel),
			vim.log.levels.WARN
		)
	end
	spec.pending = not spec.pending

	if spec.pending then
		local missing = unique(needs(state, spec), function(e) return e.to end)
		if #missing > 0 then
			vim.notify(("Enabling %s requires %s, currently disabled"):format(spec.name, table.concat(missing, ", ")), vim.log.levels.WARN)
		end
	else
		local broken = unique(breaks(state, spec), source_label)
		if #broken > 0 then
			vim.notify(("Disabling %s breaks %s"):format(spec.name, table.concat(broken, ", ")), vim.log.levels.WARN)
		end
	end
	render(state)
end

local function close(state)
	if #changed_specs(state) > 0 then
		local choice = vim.fn.confirm("Write plugin changes?", "&Yes\n&No\n&Cancel", 3)
		if choice == 1 then
			write(state)
		elseif choice ~= 2 then
			return
		end
	end
	pcall(vim.api.nvim_win_close, state.list_win, true)
end

-- Move the cursor to the next plugin row in `step` direction.
local function jump(state, step)
	local row = vim.api.nvim_win_get_cursor(state.list_win)[1] + step
	local last = vim.api.nvim_buf_line_count(state.list_buf)
	while row >= 1 and row <= last do
		if state.row_spec[row] then
			return vim.api.nvim_win_set_cursor(state.list_win, { row, 0 })
		end
		row = row + step
	end
end

local function open()
	local state = {}
	scan(state)
	state.list_buf = vim.api.nvim_create_buf(false, true)
	state.detail_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.list_buf].filetype = "plugintoggle"

	-- render the list first so its height is known
	state.list_win = -1
	render_list(state)

	local width = math.min(96, vim.o.columns - 4)
	local list_height = math.max(5, math.min(vim.api.nvim_buf_line_count(state.list_buf), vim.o.lines - detail_height - 8))
	local row = math.max(0, math.floor((vim.o.lines - list_height - detail_height - 4) / 2))
	local col = math.floor((vim.o.columns - width) / 2)
	state.list_win = vim.api.nvim_open_win(state.list_buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = list_height,
		style = "minimal",
		border = "rounded",
		title = " Plugins ",
		title_pos = "center",
		footer = " <Space> toggle · w write · q quit ",
		footer_pos = "center",
	})
	state.detail_win = vim.api.nvim_open_win(state.detail_buf, false, {
		relative = "editor",
		row = row + list_height + 2,
		col = col,
		width = width,
		height = detail_height,
		style = "minimal",
		border = "rounded",
		focusable = false,
	})
	vim.wo[state.list_win].cursorline = true
	vim.wo[state.list_win].wrap = false
	vim.wo[state.detail_win].wrap = false

	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(state.list_win),
		once = true,
		callback = function()
			pcall(vim.api.nvim_win_close, state.detail_win, true)
		end,
	})
	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = state.list_buf,
		callback = function()
			render_detail(state)
		end,
	})

	local function map(lhs, fn)
		vim.keymap.set("n", lhs, fn, { buffer = state.list_buf, nowait = true })
	end
	map("<Space>", function() toggle(state) end)
	map("<CR>", function() toggle(state) end)
	map("w", function() write(state) end)
	map("q", function() close(state) end)
	map("<Esc>", function() close(state) end)
	map("j", function() jump(state, 1) end)
	map("k", function() jump(state, -1) end)
	map("<Down>", function() jump(state, 1) end)
	map("<Up>", function() jump(state, -1) end)

	vim.api.nvim_win_set_cursor(state.list_win, { 1, 0 })
	jump(state, 1)
	render_detail(state)
end

vim.api.nvim_create_user_command("PluginToggle", open, { desc = "Enable or disable plugin specs" })
