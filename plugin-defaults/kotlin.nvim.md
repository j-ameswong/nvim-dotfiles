# kotlin.nvim defaults and configuration source

Commit: `bc8ed5523db7e0ec2c00e26a17858e4c54d86072`

These are the upstream configuration sources at the locked commit. Defaults defined in code are reproduced verbatim; documentation is included for plugins whose settings are not expressed as one Lua table.

## doc/kotlin.nvim.txt

````text
==========================================================================================
Table of Contents                                                     *kotlin.nvim.contents*

Introduction ··························································· |kotlin.nvim.intro|
Plugin Configuration ·················································· |kotlin.nvim.config|
Per-Project Configuration ··········································· |kotlin.nvim.perproject|
LSP Extensions ···················································· |kotlin.nvim.extensions|
Inlay Hints ························································ |kotlin.nvim.inlayhints|
Toggle Hints ··························································· |kotlin.nvim.hints|
Call Hierarchy ···················································· |kotlin.nvim.callhierarchy|
Folding ······························································ |kotlin.nvim.folding|
File Templates ···················································· |kotlin.nvim.filetemplates|
Workspace Management ··············································· |kotlin.nvim.workspace|
Disabling LSP ·························································· |kotlin.nvim.disable|
IntelliJ Extensions ·················································· |kotlin.nvim.intellij|
Debugging ···························································· |kotlin.nvim.debugging|

==========================================================================================

Introduction                                                       kotlin.nvim.intro*

This plugin provides advanced Kotlin support for Neovim, integrating with
`kotlin-lsp`, JetBrains' Kotlin Language Server. It offers essential features
such as class file decompilation, workspace export, diagnostic hint toggling,
inlay hints configuration, and per-project workspace isolation.

==========================================================================================

Plugin Configuration                                                *kotlin.nvim.config*

kotlin.nvim supports the following configuration options:

setup({opts})                                                          *kotlin.setup*
    Configure kotlin.nvim with the specified options.

    Parameters: ~
        {opts}  (table) Configuration options:
            • root_markers: List of files to identify project root
                Default: {"build.gradle", "build.gradle.kts", "pom.xml", "mvnw"}
                Overrides the defaults entirely when specified
            • jvm_args: Additional JVM arguments for the language server
                (passed via the IJ_JAVA_OPTIONS environment variable)
            • jdk_for_symbol_resolution: Path to JDK for symbol resolution
                (typically the JDK installation path, e.g., "/path/to/jdk-21")
                Forwarded to the server as `defaultSdk`.
            • build_tool: Preferred build importer for the workspace.
                One of: "gradle", "maven", "" (none), or nil (server picks).
                Requires kotlin-lsp v262.4739.0+. Mirrors VSCode's
                `intellij.buildTool` setting (LSP-807).
            • inlay_hints: Configuration for inlay hints (see |kotlin.nvim.inlayhints|)
                All settings default to true (except parameters_excluded,
                parameters_context and call_chains)
            • folding: { enabled = boolean } — enable LSP-driven folding
                for Kotlin buffers. Default true. Requires kotlin-lsp
                v262.4739.0+ and Neovim 0.11+.
            • file_templates: IntelliJ-style file templates for new Kotlin
                files. Pass { enabled = false } to disable, or a table of
                name → Velocity template to override the defaults (Class,
                File, Interface, Data Class, Enum, Annotation, Object).
                Requires kotlin-lsp v262.4739.0+.
            • projects: List of externally configured projects to import
                (VSCode `intellij.projects`), each
                { type = "gradle"|"maven"|"bazel"|"jps"|"json"|"subproject",
                  path = <build file or dir, absolute or relative to root>,
                  java_home = ?, env = ?, system_properties = ?,
                  project_path = ? (bazel), profiles = ? (maven),
                  download_additional_artifacts = ?, offline = ? }.
                Requires kotlin-lsp v263.4702.0+ (profiles and the two
                booleans v263.6379.0+).
            • reload_workspace: { on_build_file_save = "ask"|"always"|"never" }
                Re-import when a build file is saved. Default "ask".
                Requires kotlin-lsp v263.4702.0+.
            • code_lens: { enabled = boolean, icons = table|false,
                align = boolean } — Run/Debug lenses above `main` functions.
                Default enabled. `icons` maps the server's codicon names
                (play, debug) to text (default: Nerd Font glyphs; false =
                text only); `align` draws the lens at the line's indent
                (default true). Requires kotlin-lsp v263.4702.0+ and nvim-dap
                to execute them.
            • dap: { console = "integratedTerminal"|"internalConsole"|
                "externalTerminal", build_before_run = boolean,
                configurations = boolean }
                — where a launched program's output goes (default
                integratedTerminal), whether plain JVM launches run the
                server's build command first (default true), whether default
                entries are added to dap.configurations.kotlin/java (default
                true).
            • java_files: boolean — also attach to Java buffers of a project
                whose server is already running, like the VS Code client, so
                unsaved Java edits reach Kotlin analysis immediately. A Java
                file alone never starts the server. The Kotlin server has no
                Java language features of its own (definition, symbols,
                completion return empty). Default true.
            • data_sharing: "none"|"anonymous"|"full" — JetBrains usage
                statistics consent (INTELLIJ_DATA_SHARING). Default: unset,
                nothing is shared.
            • region: "africa"|"americas"|"apac"|"china"|"europe"|
                "middle_east"|"oceania" (INTELLIJ_REGION). Default: unset.
            • disable_rocksdb_wal: boolean — disable the index's RocksDB
                write-ahead log (VSCode `intellij.disableRocksDBWriteAheadLog`).

    Example: ~
>lua
        require("kotlin").setup {
            root_markers = { "gradlew", ".git", "settings.gradle" },
            jvm_args = { "-Xmx4g" },
            jdk_for_symbol_resolution = "/path/to/jdk-21",
            build_tool = "gradle",
            inlay_hints = {
                enabled = true,
                parameters = true,
                types_property = true,
            },
            folding = { enabled = true },
            reload_workspace = { on_build_file_save = "always" },
            projects = {
                { type = "gradle", path = "backend" },
                { type = "maven", path = "tools/pom.xml", java_home = "/path/to/jdk-17" },
            },
            dap = { console = "internalConsole" },
        }
<

==========================================================================================

Inlay Hints                                                      *kotlin.nvim.inlayhints*

kotlin.nvim provides full LSP inlay hints support. All hint types can be
individually enabled or disabled.

Requirements: ~
- kotlin-lsp version 0.254 or later
- Neovim 0.10+ with LSP inlay hints support

Quick Start: ~

Minimal configuration enables all hints with defaults:
>lua
    require("kotlin").setup {
        inlay_hints = {
            enabled = true,
        },
    }
<

Configuration Options: ~

All settings are optional and default to `true` (except `parameters_excluded`,
`parameters_context` and `call_chains` which default to `false`). Only specify
settings you want to change.

enabled                     Master switch to enable/disable all inlay hints
parameters                  Show parameter names in function calls
                            Example: foo(name: "value", age: 42)
parameters_compiled         Show parameter names for compiled/external functions
parameters_excluded         Show parameter names for excluded parameters
                            Usually kept false
parameters_context          Show context parameter hints
                            Usually kept false
types_property              Show type hints for properties
                            Example: val name: String = "foo"
types_variable              Show type hints for local variables
                            Example: val count: Int = 42
function_return             Show return type hints for functions
                            Example: fun foo(): String { }
function_parameter          Show type hints for function parameters
                            Example: fun foo(name: String) { }
lambda_return               Show return type hints for lambdas
                            Example: { x -> x * 2 }: (Int) -> Int
lambda_receivers_parameters Show receiver and parameter hints for lambdas
value_ranges                Show hints for value ranges
kotlin_time                 Show kotlin.time package warnings
call_chains                 Show intermediate result types in method-call
                            chains. Usually kept false

Complete Example: ~
>lua
    require("kotlin").setup {
        inlay_hints = {
            enabled = true,
            parameters = true,
            parameters_compiled = true,
            parameters_excluded = false,
            parameters_context = false,
            types_property = true,
            types_variable = true,
            function_return = true,
            function_parameter = true,
            lambda_return = true,
            lambda_receivers_parameters = true,
            value_ranges = true,
            kotlin_time = true,
            call_chains = false,
        },
    }
<

Commands: ~

Available Commands for Kotlin Development:

`:KotlinOrganizeImports`       Organize and optimize imports in current file
`:KotlinFormat`                Format current buffer using IntelliJ IDEA formatting
`:KotlinSymbols`               Show document symbols/outline for current buffer
`:KotlinWorkspaceSymbols`      Search for symbols across the entire workspace
`:KotlinTypeDefinition`        Go to type definition of symbol under cursor (v262+)
`:KotlinImplementation`        Go to implementation of symbol under cursor (v262+)
`:KotlinIncomingCalls`         Show callers of symbol under cursor (v262.4739.0+)
`:KotlinOutgoingCalls`         Show what symbol under cursor calls (v262.4739.0+)
`:KotlinReferences`            Find all references to symbol under cursor
`:KotlinRename`                Rename symbol under cursor across the project
`:KotlinCodeActions`           Show all available code actions from kotlin-lsp
`:KotlinQuickFix`              Show quick fixes for diagnostics on current line
`:KotlinInlayHintsToggle`      Toggle inlay hints for current buffer
`:KotlinHintsToggle`           Toggle HINT severity diagnostics
`:KotlinNewFromTemplate`       Pick an IntelliJ file template for current buffer (v262.4739.0+)
`:KotlinSupertypes`            Type hierarchy: supertypes of symbol under cursor (v263.4702.0+)
`:KotlinSubtypes`              Type hierarchy: subtypes of symbol under cursor (v263.4702.0+)
`:KotlinExportWorkspaceToJson` Export workspace structure to workspace.json
`:KotlinReloadWorkspace`       Re-import the project without a restart (v263.4702.0+)
`:KotlinRestart`               Restart the language server
`:KotlinCleanWorkspace`        Delete this project's indexes and restart
`:KotlinBuildLog`              Open the build-tool import / build output buffer
`:KotlinShowLogs`              Open the server log and Neovim's LSP log
`:KotlinRunMain [args]`        Run main() of current file (see |kotlin.nvim.debugging|)
`:KotlinDebugMain [args]`      Debug main() of current file (see |kotlin.nvim.debugging|)
`:KotlinDebug [port]`          Attach debugger to JVM (see |kotlin.nvim.debugging|)

Code Actions and Quick Fixes: ~

`:KotlinCodeActions` shows all available code actions from kotlin-lsp. These
include refactorings, quick fixes, and intentions that use the new "mod
command" system in kotlin-lsp v0.261+.

As of kotlin-lsp v262+, the following additional code actions are available:
- "Add names to call arguments"
- "Specify type explicitly"
- "Add import" quick fixes for unresolved references

`:KotlinQuickFix` filters to show only quickfix actions for diagnostics on
the current line, making it easier to fix errors and warnings.

Note: The new kotlin-lsp version uses "mod commands" instead of HINT
diagnostics for inspections. These are available via code actions rather
than being shown automatically as grayed-out text.

Inlay Hints (LSP Protocol): ~
`:KotlinInlayHintsToggle`          Toggle inlay hints for current buffer
`:lua vim.lsp.inlay_hint.enable(true)`   Enable inlay hints
`:lua vim.lsp.inlay_hint.enable(false)`  Disable inlay hints

Key Mapping Example: ~
>lua
    -- Code actions and quick fixes
    vim.keymap.set('n', '<leader>ka', ':KotlinCodeActions<CR>',
        { desc = 'Kotlin code actions' })
    vim.keymap.set('n', '<leader>kq', ':KotlinQuickFix<CR>',
        { desc = 'Kotlin quick fix' })

    -- Go to type definition
    vim.keymap.set('n', '<leader>kt', ':KotlinTypeDefinition<CR>',
        { desc = 'Go to type definition' })
    vim.keymap.set('n', '<leader>ki', ':KotlinImplementation<CR>',
        { desc = 'Go to implementation' })

    -- Organize imports
    vim.keymap.set('n', '<leader>ko', ':KotlinOrganizeImports<CR>',
        { desc = 'Organize Kotlin imports' })

    -- Format buffer
    vim.keymap.set('n', '<leader>kf', ':KotlinFormat<CR>',
        { desc = 'Format Kotlin buffer' })

    -- Show symbols outline
    vim.keymap.set('n', '<leader>ks', ':KotlinSymbols<CR>',
        { desc = 'Show document symbols' })

    -- Find references
    vim.keymap.set('n', '<leader>kr', ':KotlinReferences<CR>',
        { desc = 'Find references' })

    -- Rename symbol
    vim.keymap.set('n', '<leader>kn', ':KotlinRename<CR>',
        { desc = 'Rename symbol' })

    -- Toggle inlay hints
    vim.keymap.set('n', '<leader>ih', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, { desc = 'Toggle inlay hints' })
<

Note: ~

The `KotlinHintsToggle` command toggles diagnostic hints (HINT severity), not
inlay hints. Use `KotlinInlayHintsToggle` for LSP inlay hints.

Implementation: ~

Inlay hints work by implementing a workspace/configuration handler that
responds to server requests. kotlin-lsp requests the "jetbrains.kotlin"
configuration section on every inlay hint request, flattens the response into
dot-paths and matches them against IntelliJ's declarative inlay hint
optionIds (hints.parameters, hints.type.property, hints.lambda.return, ...).
Only hints whose optionId is answered with true are rendered, so the client
that handles this request must be the one started by kotlin.nvim.

==========================================================================================

Per-Project Configuration                                          *kotlin.nvim.perproject*

kotlin.nvim supports per-project configuration to handle different JDK versions,
memory requirements, or other settings across different Kotlin projects.

Configuration File: ~

Create a `.kotlin-lsp.lua` file in your project root directory. This file
should return a Lua table with the same structure as the global setup options.

Example `.kotlin-lsp.lua`: ~
>lua
    -- Project-specific Kotlin LSP configuration
    return {
        jdk_for_symbol_resolution = "/path/to/jdk-21",
        inlay_hints = {
            enabled = false,
        },
        jvm_args = {
            "-Xmx2g",
        },
    }
<

Behavior: ~

• Global configuration from `require("kotlin").setup()` applies to all projects
• Project configuration from `.kotlin-lsp.lua` overrides global settings
• Settings are deep-merged, with project settings taking precedence
• The file is loaded when opening a Kotlin file in that project directory

Common Use Cases: ~

1. Different JDK versions per project:
   Project A targets JDK 11, Project B targets JDK 21

2. Memory allocation:
   Large monorepos need more memory than small projects

3. Inlay hints preferences:
   Enable for some projects, disable for others

Note: ~

You can add `.kotlin-lsp.lua` to `.gitignore` for developer-specific settings,
or commit it to share configuration across your team.

==========================================================================================

LSP Extensions                                                      *kotlin.nvim.extensions*

kotlin.nvim includes additional extensions for Kotlin LSP:

M.open_classfile({fname})                                            *kotlin.open_classfile*
     Open `jdt://` or `jar://` URI, decompile class contents, and load them into the buffer.

    Parameters: ~
        {fname}  (string)

M.export_workspace_to_json()                               *kotlin.export_workspace_to_json*
    Export Kotlin LSP workspace as JSON to the current working directory.

==========================================================================================

Toggle Hints                                                             *kotlin.nvim.hints*

Toggle diagnostic hints provided by kotlin.nvim using the `KotlinHintsToggle`
command. This feature is useful for decluttering the editor interface.

Commands: ~

`:KotlinHintsToggle` - Enable or disable diagnostic hints dynamically.

==========================================================================================

Call Hierarchy                                                  *kotlin.nvim.callhierarchy*

kotlin.nvim exposes the LSP call-hierarchy capability introduced in
kotlin-lsp v262.4739.0. Place the cursor on a Kotlin function or property and
run one of the commands below.

Commands: ~

`:KotlinIncomingCalls`  Show who calls the symbol under cursor.
`:KotlinOutgoingCalls`  Show which symbols are called from the symbol under cursor.

These wrap |vim.lsp.buf.incoming_calls()| / |vim.lsp.buf.outgoing_calls()| —
results land in the location list (or |trouble.nvim| if you have it bound to
the location list).

==========================================================================================

Folding                                                                *kotlin.nvim.folding*

When kotlin-lsp v262.4739.0+ is attached, the plugin sets the buffer's
foldexpr to |vim.lsp.foldexpr()| and foldmethod to "expr", so functions,
classes, blocks, imports, and multiline comments fold using the server's
folding-range information.

Disable per-buffer with `:setlocal nofoldenable`, or globally via:
>lua
    require("kotlin").setup {
        folding = { enabled = false },
    }
<

==========================================================================================

File Templates                                                    *kotlin.nvim.filetemplates*

When you create a new `*.kt` file the plugin asks kotlin-lsp v262.4739.0+ to
interpolate an IntelliJ-style file template (Class, File, Interface, Data
Class, Enum, Annotation, Object). The chosen template is rendered with
predefined variables (${PACKAGE_NAME}, ${NAME}, ${USER}, ${DATE}, …) and
inserted into the buffer; a literal `|` in the template becomes the cursor
position.

Commands: ~

`:KotlinNewFromTemplate`  Pick a template and apply it to the current buffer.

Configuration: ~
>lua
    require("kotlin").setup {
        file_templates = {
            -- enabled = false,  -- disable the prompt entirely
            Class = "package ${PACKAGE_NAME}\n\nclass ${NAME} {\n\t|\n}",
        },
    }
<

==========================================================================================

Workspace Management                                                *kotlin.nvim.workspace*

kotlin.nvim gives every project its own `--system-path` directory so the
server's state (indexes, logs, caches) never mixes between projects.

Directory: ~

Unix/Linux/macOS:
```
~/.cache/kotlin-lsp-workspaces/{project-name}-{hash}/
```

Windows:
```
%LOCALAPPDATA%\kotlin-lsp-workspaces\{project-name}-{hash}\
```

`{project-name}` is the resolved project root's directory name and `{hash}`
the first 8 hex digits of the sha256 of its absolute path, so two projects
with the same name do not share state. The server log is at
`<system-path>/system/log/intellij-server.log` (`:KotlinShowLogs`).

On kotlin-lsp v263.4702.0+ the index lives inside that directory and the
server reports its exact location in `capabilities.experimental.indexDir`
(shown by `:checkhealth kotlin`).

Commands: ~

`:KotlinReloadWorkspace`  Ask the server to re-import the project
                         (`intellij/reloadWorkspace`, v263.4702.0+). The
                         initialization options — `build_tool`, `projects`,
                         `jdk_for_symbol_resolution` — are sent again, so
                         changing them in `.kotlin-lsp.lua` takes effect
                         without a restart. The process and its indexes stay.

`:KotlinRestart`          Stop and start the server for all Kotlin buffers.

`:KotlinCleanWorkspace`   Stop the server, delete the project's system-path
                         directory and the index directory the server
                         reported, then start again. Nothing outside this
                         project is touched.

`:KotlinBuildLog`         Output of Gradle/Maven imports (`intellij/importLog`)
                         and of builds run before a launch.

Auto reload: ~

With `reload_workspace.on_build_file_save` (default `"ask"`) saving
`build.gradle(.kts)`, `settings.gradle(.kts)` or `pom.xml` offers to
re-import the project; `"always"` does it silently, `"never"` disables it.

Import status: ~

The server reports folders whose import cannot start
(`intellij/workspaceImportStatus`). A folder holding several build systems
is reported as a warning: set `build_tool` and run `:KotlinReloadWorkspace`.

Build expiry: ~

kotlin-lsp builds embed a time-limited licence. When it runs out the launcher
exits with code 7 and the server never starts; kotlin.nvim reports this and
`:checkhealth kotlin` shows the licence status and date. Update kotlin-lsp.

==========================================================================================

Kotlin Package Oil Resolution                                         *kotlin.nvim.oil*

kotlin.nvim supports Kotlin package resolution, allowing you to easily
navigate to package folders declared in your Kotlin projects.

This feature leverages the LSP's (Language Server Protocol) "go to definition"
functionality: when you use "go to definition" (`gd`) on a package name, if
the LSP returns a response for the package—it jumps directly to the
corresponding package folder using an oil.nvim buffer.

Note: ~

No additional configuration is required for this feature. It works out of the box
if the LSP supports and returns a response for the package reference.

==========================================================================================

Disabling LSP                                                        *kotlin.nvim.disable*

kotlin.nvim allows you to disable the Kotlin LSP on a per-project basis using
a marker file. This is useful for projects where you don't want the language
server to run, since it does not support all kinds of projects yet.

Usage: ~

To disable the Kotlin LSP for a specific project, create a `.disable-kotlin-lsp`
file in the project root directory.

Example:
```
cd /path/to/your/kotlin/project
touch .disable-kotlin-lsp
```

When the plugin detects this marker file, it will skip LSP initialization.
The marker file can be an empty file—only its presence is checked.

Note: ~

The plugin searches upward from the opened file's directory to find the marker
file, so it works regardless of your current working directory.

==========================================================================================

IntelliJ Extensions                                                *kotlin.nvim.intellij*

kotlin-lsp v263.4702.0+ exposes most IntelliJ Kotlin intentions as code
actions, but only to clients that declare `intellijExtensions = true` in the
initialization options, because some of them need the editor:

`intellij/chooseAction`      A "choose one" menu (e.g. which expression to
                             extract). Shown with |vim.ui.select()|; the pick
                             runs the command its entry carries (older servers:
                             `chooseModCommandAction`).
`intellij/showConflicts`     A refactoring (Move, Extract variable) reports
                             problems and asks to continue (v263.6379.0+).
                             Shown with |vim.ui.select()|; picking a conflict
                             opens its code, closing the menu cancels.
`intellij/copyToClipboard`   Text copied to the `+` and `"` registers.
`intellij/runEditorCommand`  `editor.action.rename` → |vim.lsp.buf.rename()|,
                             `editor.action.triggerSuggest` → completion,
                             `editor.action.triggerParameterHints` →
                             |vim.lsp.buf.signature_help()|.
`intellij/importLog`         Build-import output → `:KotlinBuildLog`.
`intellij/workspaceImportStatus`
                             Folders whose import is blocked → notification.

kotlin.nvim always sends the flag and installs these handlers. The server
also emits `intellij.jvm.runMain` code lenses (see |kotlin.nvim.debugging|).

Hover markdown from the server may contain `command:` links that only VS Code
can follow; kotlin.nvim strips the link and keeps its label.

Library sources: ~

Go-to-definition into a dependency or the JDK yields `jar:` / `jrt:`
locations. The buffer is filled through the server's `decompile` command,
made read-only (`buftype=nowrite`) and attached to the kotlin_lsp client, so
hover, navigation and semantic highlighting work inside library sources.
Buffers open before a server restart are re-attached.

Semantic tokens: ~

The server never asks for a semantic-token refresh after indexing, so buffers
opened during indexing kept stale highlighting; kotlin.nvim refreshes them when
the "Indexing" progress ends.

Live templates: ~

Completion items for `main`, `sout`, `fori`, … (v263.4702.0+) use the same
server-driven apply command as ordinary items, so they work with every
completion engine.

==========================================================================================

Debugging                                                        *kotlin.nvim.debugging*

kotlin.nvim integrates with nvim-dap and kotlin-lsp's built-in debug
adapter. When a session starts, the plugin sends `start_debug_server` to
kotlin-lsp, which spins up a DAP server and returns the port to connect to.

Requirements: ~
- nvim-dap (https://github.com/mfussenegger/nvim-dap) must be installed
- kotlin-lsp must be running (open a Kotlin file first)
- Launching (as opposed to attaching) needs kotlin-lsp v263.4702.0+

Commands: ~

`:KotlinRunMain [args]`    Run the `main` function of the current buffer.
                          Extra words are passed as program arguments.
`:KotlinDebugMain [args]`  Same, under the debugger.
`:KotlinDebug [port]`      Attach the debugger to a running Kotlin/JVM
                          process. Optionally specify the JDWP port
                          (default: 5005). If no port is given, you will be
                          prompted.

Run/Debug code lenses: ~

Every `main` function gets "Run" and "Debug" lenses (|vim.lsp.codelens|).
Trigger the one on the cursor line with `vim.lsp.codelens.run()`. Disable
with `code_lens = { enabled = false }`.

How a launch is resolved: ~

The server decides, like the VS Code extension:
- A Gradle module is launched through Gradle
  (`intellij.java.resolveBuildToolLaunch`); Gradle compiles and runs.
- Otherwise the server returns the runtime paths
  (`intellij.java.resolveLaunch`: java executable, classpath, module path,
  working directory) and a build command (`intellij.java.resolveBuildCommand`).
  kotlin.nvim runs the build first (output in `:KotlinBuildLog`) and starts
  the program only if it succeeds; `dap.build_before_run = false` skips it.

Program output goes to a terminal split (`dap.console = "integratedTerminal"`,
DAP `runInTerminal`) or to the nvim-dap REPL (`"internalConsole"`).

nvim-dap configurations and launch.json: ~

The resolution runs in the adapter's `enrich_config` hook, so any launch
configuration of type `kotlin` only needs `mainClass`. `dap.continue()`
offers "Launch main class", "Launch main class (plain JVM)" and "Attach to
JVM" by default (`dap.configurations = false` to opt out). A
`.vscode/launch.json` written for the VS Code extension works unchanged: its
`intellij_jvm`, `intellij_gradle` and `intellij_debugger` types map to the
same adapter. Recognized fields: mainClass, file, args, vmArgs, env, cwd,
console, launcher ("auto"|"gradle"|"jvm"), build (boolean), classPaths,
modulePaths, moduleName, javaExec, projectPath, sourceSet, gradleArgs.
>lua
    table.insert(require("dap").configurations.kotlin, {
        type = "kotlin", request = "launch", name = "Run server",
        mainClass = "com.example.ServerKt",
        launcher = "gradle",
        args = { "--port", "8080" },
    })
<

Programmatic launch: ~
>lua
    require("kotlin.dap").run_main({
        mainClass = "com.example.MainKt",
        noDebug = true,        -- false = debug
        launcher = "jvm",      -- "gradle" | "jvm" | nil (server decides)
        args = { "--verbose" },
        vmArgs = { "-Xmx1g" },
        env = { APP_ENV = "dev" },
    })
<

Attach usage: ~

1. Start your Kotlin application with JDWP debugging enabled:

   Gradle:
>sh
    ./gradlew run --debug-jvm
<
   Maven (tests):
>sh
    mvn test -Dmaven.surefire.debug
<
   Both default to port 5005.

2. Open a Kotlin file to activate kotlin-lsp

3. Set breakpoints with nvim-dap:
>lua
    require("dap").toggle_breakpoint()
<

4. Attach the debugger:
>vim
    :KotlinDebug          " prompts for port (default 5005)
    :KotlinDebug 5005     " attach to port 5005 directly
    :KotlinDebug 8000     " attach to a custom port
<

Configuration: ~

The plugin registers a `kotlin` DAP adapter automatically (adapter id
`intellij_jvm`). It is only set if not already configured by the user, so
you can override it:
>lua
    local dap = require("dap")

    -- Custom adapter (optional, plugin registers one automatically)
    dap.adapters.kotlin = function(cb, config)
        -- your custom adapter logic
    end
<

You can also call the attach function programmatically:
>lua
    require("kotlin.dap").start({ port = 5005 })
<

Key Mapping Example: ~
>lua
    vim.keymap.set('n', '<leader>kr', ':KotlinRunMain<CR>',
        { desc = 'Run Kotlin main' })
    vim.keymap.set('n', '<leader>kd', ':KotlinDebugMain<CR>',
        { desc = 'Debug Kotlin main' })
    vim.keymap.set('n', '<leader>ka', ':KotlinDebug<CR>',
        { desc = 'Attach Kotlin debugger' })
    vim.keymap.set('n', '<leader>db', function()
        require("dap").toggle_breakpoint()
    end, { desc = 'Toggle breakpoint' })
<

Note: ~

nvim-dap is an optional dependency. If it is not installed, DAP features
are silently skipped and the rest of the plugin works normally.

==========================================================================================

vim:tw=78:ts=8:noet:ft=help:norl:

````

## LICENSE.txt

```text

                    GNU GENERAL PUBLIC LICENSE
                       Version 3, 29 June 2007

 Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

                            Preamble

  The GNU General Public License is a free, copyleft license for
software and other kinds of works.

  The licenses for most software and other practical works are designed
to take away your freedom to share and change the works.  By contrast,
the GNU General Public License is intended to guarantee your freedom to
share and change all versions of a program--to make sure it remains free
software for all its users.  We, the Free Software Foundation, use the
GNU General Public License for most of our software; it applies also to
any other work released this way by its authors.  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
them if you wish), that you receive source code or can get it if you
want it, that you can change the software or use pieces of it in new
free programs, and that you know you can do these things.

  To protect your rights, we need to prevent others from denying you
these rights or asking you to surrender the rights.  Therefore, you have
certain responsibilities if you distribute copies of the software, or if
you modify it: responsibilities to respect the freedom of others.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must pass on to the recipients the same
freedoms that you received.  You must make sure that they, too, receive
or can get the source code.  And you must show them these terms so they
know their rights.

  Developers that use the GNU GPL protect your rights with two steps:
(1) assert copyright on the software, and (2) offer you this License
giving you legal permission to copy, distribute and/or modify it.

  For the developers' and authors' protection, the GPL clearly explains
that there is no warranty for this free software.  For both users' and
authors' sake, the GPL requires that modified versions be marked as
changed, so that their problems will not be attributed erroneously to
authors of previous versions.

  Some devices are designed to deny users access to install or run
modified versions of the software inside them, although the manufacturer
can do so.  This is fundamentally incompatible with the aim of
protecting users' freedom to change the software.  The systematic
pattern of such abuse occurs in the area of products for individuals to
use, which is precisely where it is most unacceptable.  Therefore, we
have designed this version of the GPL to prohibit the practice for those
products.  If such problems arise substantially in other domains, we
stand ready to extend this provision to those domains in future versions
of the GPL, as needed to protect the freedom of users.

  Finally, every program is threatened constantly by software patents.
States should not allow patents to restrict development and use of
software on general-purpose computers, but in those that do, we wish to
avoid the special danger that patents applied to a free program could
make it effectively proprietary.  To prevent this, the GPL assures that
patents cannot be used to render the program non-free.

  The precise terms and conditions for copying, distribution and
modification follow.

                       TERMS AND CONDITIONS

  0. Definitions.

  "This License" refers to version 3 of the GNU General Public License.

  "Copyright" also means copyright-like laws that apply to other kinds of
works, such as semiconductor masks.

  "The Program" refers to any copyrightable work licensed under this
License.  Each licensee is addressed as "you".  "Licensees" and
"recipients" may be individuals or organizations.

  To "modify" a work means to copy from or adapt all or part of the work
in a fashion requiring copyright permission, other than the making of an
exact copy.  The resulting work is called a "modified version" of the
earlier work or a work "based on" the earlier work.

  A "covered work" means either the unmodified Program or a work based
on the Program.

  To "propagate" a work means to do anything with it that, without
permission, would make you directly or secondarily liable for
infringement under applicable copyright law, except executing it on a
computer or modifying a private copy.  Propagation includes copying,
distribution (with or without modification), making available to the
public, and in some countries other activities as well.

  To "convey" a work means any kind of propagation that enables other
parties to make or receive copies.  Mere interaction with a user through
a computer network, with no transfer of a copy, is not conveying.

  An interactive user interface displays "Appropriate Legal Notices"
to the extent that it includes a convenient and prominently visible
feature that (1) displays an appropriate copyright notice, and (2)
tells the user that there is no warranty for the work (except to the
extent that warranties are provided), that licensees may convey the
work under this License, and how to view a copy of this License.  If
the interface presents a list of user commands or options, such as a
menu, a prominent item in the list meets this criterion.

  1. Source Code.

  The "source code" for a work means the preferred form of the work
for making modifications to it.  "Object code" means any non-source
form of a work.

  A "Standard Interface" means an interface that either is an official
standard defined by a recognized standards body, or, in the case of
interfaces specified for a particular programming language, one that
is widely used among developers working in that language.

  The "System Libraries" of an executable work include anything, other
than the work as a whole, that (a) is included in the normal form of
packaging a Major Component, but which is not part of that Major
Component, and (b) serves only to enable use of the work with that
Major Component, or to implement a Standard Interface for which an
implementation is available to the public in source code form.  A
"Major Component", in this context, means a major essential component
(kernel, window system, and so on) of the specific operating system
(if any) on which the executable work runs, or a compiler used to
produce the work, or an object code interpreter used to run it.

  The "Corresponding Source" for a work in object code form means all
the source code needed to generate, install, and (for an executable
work) run the object code and to modify the work, including scripts to
control those activities.  However, it does not include the work's
System Libraries, or general-purpose tools or generally available free
programs which are used unmodified in performing those activities but
which are not part of the work.  For example, Corresponding Source
includes interface definition files associated with source files for
the work, and the source code for shared libraries and dynamically
linked subprograms that the work is specifically designed to require,
such as by intimate data communication or control flow between those
subprograms and other parts of the work.

  The Corresponding Source need not include anything that users
can regenerate automatically from other parts of the Corresponding
Source.

  The Corresponding Source for a work in source code form is that
same work.

  2. Basic Permissions.

  All rights granted under this License are granted for the term of
copyright on the Program, and are irrevocable provided the stated
conditions are met.  This License explicitly affirms your unlimited
permission to run the unmodified Program.  The output from running a
covered work is covered by this License only if the output, given its
content, constitutes a covered work.  This License acknowledges your
rights of fair use or other equivalent, as provided by copyright law.

  You may make, run and propagate covered works that you do not
convey, without conditions so long as your license otherwise remains
in force.  You may convey covered works to others for the sole purpose
of having them make modifications exclusively for you, or provide you
with facilities for running those works, provided that you comply with
the terms of this License in conveying all material for which you do
not control copyright.  Those thus making or running the covered works
for you must do so exclusively on your behalf, under your direction
and control, on terms that prohibit them from making any copies of
your copyrighted material outside their relationship with you.

  Conveying under any other circumstances is permitted solely under
the conditions stated below.  Sublicensing is not allowed; section 10
makes it unnecessary.

  3. Protecting Users' Legal Rights From Anti-Circumvention Law.

  No covered work shall be deemed part of an effective technological
measure under any applicable law fulfilling obligations under article
11 of the WIPO copyright treaty adopted on 20 December 1996, or
similar laws prohibiting or restricting circumvention of such
measures.

  When you convey a covered work, you waive any legal power to forbid
circumvention of technological measures to the extent such circumvention
is effected by exercising rights under this License with respect to
the covered work, and you disclaim any intention to limit operation or
modification of the work as a means of enforcing, against the work's
users, your or third parties' legal rights to forbid circumvention of
technological measures.

  4. Conveying Verbatim Copies.

  You may convey verbatim copies of the Program's source code as you
receive it, in any medium, provided that you conspicuously and
appropriately publish on each copy an appropriate copyright notice;
keep intact all notices stating that this License and any
non-permissive terms added in accord with section 7 apply to the code;
keep intact all notices of the absence of any warranty; and give all
recipients a copy of this License along with the Program.

  You may charge any price or no price for each copy that you convey,
and you may offer support or warranty protection for a fee.

  5. Conveying Modified Source Versions.

  You may convey a work based on the Program, or the modifications to
produce it from the Program, in the form of source code under the
terms of section 4, provided that you also meet all of these conditions:

    a) The work must carry prominent notices stating that you modified
    it, and giving a relevant date.

    b) The work must carry prominent notices stating that it is
    released under this License and any conditions added under section
    7.  This requirement modifies the requirement in section 4 to
    "keep intact all notices".

    c) You must license the entire work, as a whole, under this
    License to anyone who comes into possession of a copy.  This
    License will therefore apply, along with any applicable section 7
    additional terms, to the whole of the work, and all its parts,
    regardless of how they are packaged.  This License gives no
    permission to license the work in any other way, but it does not
    invalidate such permission if you have separately received it.

    d) If the work has interactive user interfaces, each must display
    Appropriate Legal Notices; however, if the Program has interactive
    interfaces that do not display Appropriate Legal Notices, your
    work need not make them do so.

  A compilation of a covered work with other separate and independent
works, which are not by their nature extensions of the covered work,
and which are not combined with it such as to form a larger program,
in or on a volume of a storage or distribution medium, is called an
"aggregate" if the compilation and its resulting copyright are not
used to limit the access or legal rights of the compilation's users
beyond what the individual works permit.  Inclusion of a covered work
in an aggregate does not cause this License to apply to the other
parts of the aggregate.

  6. Conveying Non-Source Forms.

  You may convey a covered work in object code form under the terms
of sections 4 and 5, provided that you also convey the
machine-readable Corresponding Source under the terms of this License,
in one of these ways:

    a) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by the
    Corresponding Source fixed on a durable physical medium
    customarily used for software interchange.

    b) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by a
    written offer, valid for at least three years and valid for as
    long as you offer spare parts or customer support for that product
    model, to give anyone who possesses the object code either (1) a
    copy of the Corresponding Source for all the software in the
    product that is covered by this License, on a durable physical
    medium customarily used for software interchange, for a price no
    more than your reasonable cost of physically performing this
    conveying of source, or (2) access to copy the
    Corresponding Source from a network server at no charge.

    c) Convey individual copies of the object code with a copy of the
    written offer to provide the Corresponding Source.  This
    alternative is allowed only occasionally and noncommercially, and
    only if you received the object code with such an offer, in accord
    with subsection 6b.

    d) Convey the object code by offering access from a designated
    place (gratis or for a charge), and offer equivalent access to the
    Corresponding Source in the same way through the same place at no
    further charge.  You need not require recipients to copy the
    Corresponding Source along with the object code.  If the place to
    copy the object code is a network server, the Corresponding Source
    may be on a different server (operated by you or a third party)
    that supports equivalent copying facilities, provided you maintain
    clear directions next to the object code saying where to find the
    Corresponding Source.  Regardless of what server hosts the
    Corresponding Source, you remain obligated to ensure that it is
    available for as long as needed to satisfy these requirements.

    e) Convey the object code using peer-to-peer transmission, provided
    you inform other peers where the object code and Corresponding
    Source of the work are being offered to the general public at no
    charge under subsection 6d.

  A separable portion of the object code, whose source code is excluded
from the Corresponding Source as a System Library, need not be
included in conveying the object code work.

  A "User Product" is either (1) a "consumer product", which means any
tangible personal property which is normally used for personal, family,
or household purposes, or (2) anything designed or sold for incorporation
into a dwelling.  In determining whether a product is a consumer product,
doubtful cases shall be resolved in favor of coverage.  For a particular
product received by a particular user, "normally used" refers to a
typical or common use of that class of product, regardless of the status
of the particular user or of the way in which the particular user
actually uses, or expects or is expected to use, the product.  A product
is a consumer product regardless of whether the product has substantial
commercial, industrial or non-consumer uses, unless such uses represent
the only significant mode of use of the product.

  "Installation Information" for a User Product means any methods,
procedures, authorization keys, or other information required to install
and execute modified versions of a covered work in that User Product from
a modified version of its Corresponding Source.  The information must
suffice to ensure that the continued functioning of the modified object
code is in no case prevented or interfered with solely because
modification has been made.

  If you convey an object code work under this section in, or with, or
specifically for use in, a User Product, and the conveying occurs as
part of a transaction in which the right of possession and use of the
User Product is transferred to the recipient in perpetuity or for a
fixed term (regardless of how the transaction is characterized), the
Corresponding Source conveyed under this section must be accompanied
by the Installation Information.  But this requirement does not apply
if neither you nor any third party retains the ability to install
modified object code on the User Product (for example, the work has
been installed in ROM).

  The requirement to provide Installation Information does not include a
requirement to continue to provide support service, warranty, or updates
for a work that has been modified or installed by the recipient, or for
the User Product in which it has been modified or installed.  Access to a
network may be denied when the modification itself materially and
adversely affects the operation of the network or violates the rules and
protocols for communication across the network.

  Corresponding Source conveyed, and Installation Information provided,
in accord with this section must be in a format that is publicly
documented (and with an implementation available to the public in
source code form), and must require no special password or key for
unpacking, reading or copying.

  7. Additional Terms.

  "Additional permissions" are terms that supplement the terms of this
License by making exceptions from one or more of its conditions.
Additional permissions that are applicable to the entire Program shall
be treated as though they were included in this License, to the extent
that they are valid under applicable law.  If additional permissions
apply only to part of the Program, that part may be used separately
under those permissions, but the entire Program remains governed by
this License without regard to the additional permissions.

  When you convey a copy of a covered work, you may at your option
remove any additional permissions from that copy, or from any part of
it.  (Additional permissions may be written to require their own
removal in certain cases when you modify the work.)  You may place
additional permissions on material, added by you to a covered work,
for which you have or can give appropriate copyright permission.

  Notwithstanding any other provision of this License, for material you
add to a covered work, you may (if authorized by the copyright holders of
that material) supplement the terms of this License with terms:

    a) Disclaiming warranty or limiting liability differently from the
    terms of sections 15 and 16 of this License; or

    b) Requiring preservation of specified reasonable legal notices or
    author attributions in that material or in the Appropriate Legal
    Notices displayed by works containing it; or

    c) Prohibiting misrepresentation of the origin of that material, or
    requiring that modified versions of such material be marked in
    reasonable ways as different from the original version; or

    d) Limiting the use for publicity purposes of names of licensors or
    authors of the material; or

    e) Declining to grant rights under trademark law for use of some
    trade names, trademarks, or service marks; or

    f) Requiring indemnification of licensors and authors of that
    material by anyone who conveys the material (or modified versions of
    it) with contractual assumptions of liability to the recipient, for
    any liability that these contractual assumptions directly impose on
    those licensors and authors.

  All other non-permissive additional terms are considered "further
restrictions" within the meaning of section 10.  If the Program as you
received it, or any part of it, contains a notice stating that it is
governed by this License along with a term that is a further
restriction, you may remove that term.  If a license document contains
a further restriction but permits relicensing or conveying under this
License, you may add to a covered work material governed by the terms
of that license document, provided that the further restriction does
not survive such relicensing or conveying.

  If you add terms to a covered work in accord with this section, you
must place, in the relevant source files, a statement of the
additional terms that apply to those files, or a notice indicating
where to find the applicable terms.

  Additional terms, permissive or non-permissive, may be stated in the
form of a separately written license, or stated as exceptions;
the above requirements apply either way.

  8. Termination.

  You may not propagate or modify a covered work except as expressly
provided under this License.  Any attempt otherwise to propagate or
modify it is void, and will automatically terminate your rights under
this License (including any patent licenses granted under the third
paragraph of section 11).

  However, if you cease all violation of this License, then your
license from a particular copyright holder is reinstated (a)
provisionally, unless and until the copyright holder explicitly and
finally terminates your license, and (b) permanently, if the copyright
holder fails to notify you of the violation by some reasonable means
prior to 60 days after the cessation.

  Moreover, your license from a particular copyright holder is
reinstated permanently if the copyright holder notifies you of the
violation by some reasonable means, this is the first time you have
received notice of violation of this License (for any work) from that
copyright holder, and you cure the violation prior to 30 days after
your receipt of the notice.

  Termination of your rights under this section does not terminate the
licenses of parties who have received copies or rights from you under
this License.  If your rights have been terminated and not permanently
reinstated, you do not qualify to receive new licenses for the same
material under section 10.

  9. Acceptance Not Required for Having Copies.

  You are not required to accept this License in order to receive or
run a copy of the Program.  Ancillary propagation of a covered work
occurring solely as a consequence of using peer-to-peer transmission
to receive a copy likewise does not require acceptance.  However,
nothing other than this License grants you permission to propagate or
modify any covered work.  These actions infringe copyright if you do
not accept this License.  Therefore, by modifying or propagating a
covered work, you indicate your acceptance of this License to do so.

  10. Automatic Licensing of Downstream Recipients.

  Each time you convey a covered work, the recipient automatically
receives a license from the original licensors, to run, modify and
propagate that work, subject to this License.  You are not responsible
for enforcing compliance by third parties with this License.

  An "entity transaction" is a transaction transferring control of an
organization, or substantially all assets of one, or subdividing an
organization, or merging organizations.  If propagation of a covered
work results from an entity transaction, each party to that
transaction who receives a copy of the work also receives whatever
licenses to the work the party's predecessor in interest had or could
give under the previous paragraph, plus a right to possession of the
Corresponding Source of the work from the predecessor in interest, if
the predecessor has it or can get it with reasonable efforts.

  You may not impose any further restrictions on the exercise of the
rights granted or affirmed under this License.  For example, you may
not impose a license fee, royalty, or other charge for exercise of
rights granted under this License, and you may not initiate litigation
(including a cross-claim or counterclaim in a lawsuit) alleging that
any patent claim is infringed by making, using, selling, offering for
sale, or importing the Program or any portion of it.

  11. Patents.

  A "contributor" is a copyright holder who authorizes use under this
License of the Program or a work on which the Program is based.  The
work thus licensed is called the contributor's "contributor version".

  A contributor's "essential patent claims" are all patent claims
owned or controlled by the contributor, whether already acquired or
hereafter acquired, that would be infringed by some manner, permitted
by this License, of making, using, or selling its contributor version,
but do not include claims that would be infringed only as a
consequence of further modification of the contributor version.  For
purposes of this definition, "control" includes the right to grant
patent sublicenses in a manner consistent with the requirements of
this License.

  Each contributor grants you a non-exclusive, worldwide, royalty-free
patent license under the contributor's essential patent claims, to
make, use, sell, offer for sale, import and otherwise run, modify and
propagate the contents of its contributor version.

  In the following three paragraphs, a "patent license" is any express
agreement or commitment, however denominated, not to enforce a patent
(such as an express permission to practice a patent or covenant not to
sue for patent infringement).  To "grant" such a patent license to a
party means to make such an agreement or commitment not to enforce a
patent against the party.

  If you convey a covered work, knowingly relying on a patent license,
and the Corresponding Source of the work is not available for anyone
to copy, free of charge and under the terms of this License, through a
publicly available network server or other readily accessible means,
then you must either (1) cause the Corresponding Source to be so
available, or (2) arrange to deprive yourself of the benefit of the
patent license for this particular work, or (3) arrange, in a manner
consistent with the requirements of this License, to extend the patent
license to downstream recipients.  "Knowingly relying" means you have
actual knowledge that, but for the patent license, your conveying the
covered work in a country, or your recipient's use of the covered work
in a country, would infringe one or more identifiable patents in that
country that you have reason to believe are valid.

  If, pursuant to or in connection with a single transaction or
arrangement, you convey, or propagate by procuring conveyance of, a
covered work, and grant a patent license to some of the parties
receiving the covered work authorizing them to use, propagate, modify
or convey a specific copy of the covered work, then the patent license
you grant is automatically extended to all recipients of the covered
work and works based on it.

  A patent license is "discriminatory" if it does not include within
the scope of its coverage, prohibits the exercise of, or is
conditioned on the non-exercise of one or more of the rights that are
specifically granted under this License.  You may not convey a covered
work if you are a party to an arrangement with a third party that is
in the business of distributing software, under which you make payment
to the third party based on the extent of your activity of conveying
the work, and under which the third party grants, to any of the
parties who would receive the covered work from you, a discriminatory
patent license (a) in connection with copies of the covered work
conveyed by you (or copies made from those copies), or (b) primarily
for and in connection with specific products or compilations that
contain the covered work, unless you entered into that arrangement,
or that patent license was granted, prior to 28 March 2007.

  Nothing in this License shall be construed as excluding or limiting
any implied license or other defenses to infringement that may
otherwise be available to you under applicable patent law.

  12. No Surrender of Others' Freedom.

  If conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot convey a
covered work so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you may
not convey it at all.  For example, if you agree to terms that obligate you
to collect a royalty for further conveying from those to whom you convey
the Program, the only way you could satisfy both those terms and this
License would be to refrain entirely from conveying the Program.

  13. Use with the GNU Affero General Public License.

  Notwithstanding any other provision of this License, you have
permission to link or combine any covered work with a work licensed
under version 3 of the GNU Affero General Public License into a single
combined work, and to convey the resulting work.  The terms of this
License will continue to apply to the part which is the covered work,
but the special requirements of the GNU Affero General Public License,
section 13, concerning interaction through a network will apply to the
combination as such.

  14. Revised Versions of this License.

  The Free Software Foundation may publish revised and/or new versions of
the GNU General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

  Each version is given a distinguishing version number.  If the
Program specifies that a certain numbered version of the GNU General
Public License "or any later version" applies to it, you have the
option of following the terms and conditions either of that numbered
version or of any later version published by the Free Software
Foundation.  If the Program does not specify a version number of the
GNU General Public License, you may choose any version ever published
by the Free Software Foundation.

  If the Program specifies that a proxy can decide which future
versions of the GNU General Public License can be used, that proxy's
public statement of acceptance of a version permanently authorizes you
to choose that version for the Program.

  Later license versions may give you additional or different
permissions.  However, no additional obligations are imposed on any
author or copyright holder as a result of your choosing to follow a
later version.

  15. Disclaimer of Warranty.

  THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY
OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

  16. Limitation of Liability.

  IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS
THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF
DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD
PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),
EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

  17. Interpretation of Sections 15 and 16.

  If the disclaimer of warranty and limitation of liability provided
above cannot be given local legal effect according to their terms,
reviewing courts shall apply local law that most closely approximates
an absolute waiver of all civil liability in connection with the
Program, unless a warranty or assumption of liability accompanies a
copy of the Program in return for a fee.

                     END OF TERMS AND CONDITIONS

            How to Apply These Terms to Your New Programs

  If you develop a new program, and you want it to be of the greatest
possible use to the public, the best way to achieve this is to make it
free software which everyone can redistribute and change under these terms.

  To do so, attach the following notices to the program.  It is safest
to attach them to the start of each source file to most effectively
state the exclusion of warranty; and each file should have at least
the "copyright" line and a pointer to where the full notice is found.

    <one line to give the program's name and a brief idea of what it does.>
    Copyright (C) <year>  <name of author>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

Also add information on how to contact you by electronic and paper mail.

  If the program does terminal interaction, make it output a short
notice like this when it starts in an interactive mode:

    <program>  Copyright (C) <year>  <name of author>
    This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type `show c' for details.

The hypothetical commands `show w' and `show c' should show the appropriate
parts of the General Public License.  Of course, your program's commands
might be different; for a GUI interface, you would use an "about box".

  You should also get your employer (if you work as a programmer) or school,
if any, to sign a "copyright disclaimer" for the program, if necessary.
For more information on this, and how to apply and follow the GNU GPL, see
<http://www.gnu.org/licenses/>.

  The GNU General Public License does not permit incorporating your program
into proprietary programs.  If your program is a subroutine library, you
may consider it more useful to permit linking proprietary applications with
the library.  If this is what you want to do, use the GNU Lesser General
Public License instead of this License.  But first, please read
<http://www.gnu.org/philosophy/why-not-lgpl.html>.

```
