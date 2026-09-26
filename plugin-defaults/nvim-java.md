# nvim-java defaults and configuration source

Commit: `db5536b4cb3da153084e50016596fd0e3a319aae`

These are the upstream configuration sources at the locked commit. Defaults defined in code are reproduced verbatim; documentation is included for plugins whose settings are not expressed as one Lua table.

## lua/java/config.lua

```lua
local JDTLS_VERSION = '1.54.0'

local jdtls_version_map = {
	['1.43.0'] = {
		lombok = '1.18.40',
		java_test = '0.40.1',
		java_debug_adapter = '0.58.2',
		spring_boot_tools = '1.55.1',
		jdk = '17',
	},
	['1.54.0'] = {
		lombok = '1.18.42',
		java_test = '0.43.2',
		java_debug_adapter = '0.58.3',
		spring_boot_tools = '1.55.1',
		jdk = '25',
	},
}

local V = jdtls_version_map[JDTLS_VERSION]

---@class java.Config
---@field checks { nvim_version: boolean, nvim_jdtls_conflict: boolean }
---@field jdtls { version: string, path: string|nil, auto_install: boolean }
---@field lombok { enable: boolean, version: string, path: string|nil, auto_install: boolean }
---@field java_test { enable: boolean, version: string, path: string|nil, auto_install: boolean }
---@field java_debug_adapter { enable: boolean, version: string, path: string|nil, auto_install: boolean }
---@field spring_boot_tools { enable: boolean, version: string, path: string|nil, auto_install: boolean }
---@field jdk { auto_install: boolean, version: string, path: string|nil }
---@field experimental { fix_generated_sources: boolean }
---@field log java-core.Log2Config

---@class java.PartialConfig
---@field checks? { nvim_version?: boolean, nvim_jdtls_conflict?: boolean }
---@field jdtls? { version?: string, path?: string, auto_install?: boolean }
---@field lombok? { enable?: boolean, version?: string, path?: string, auto_install?: boolean }
---@field java_test? { enable?: boolean, version?: string, path?: string, auto_install?: boolean }
---@field java_debug_adapter? { enable?: boolean, version?: string, path?: string, auto_install?: boolean }
---@field spring_boot_tools? { enable?: boolean, version?: string, path?: string, auto_install?: boolean }
---@field jdk? { auto_install?: boolean, version?: string, path?: string }
---@field experimental? { fix_generated_sources?: boolean }
---@field log? java-core.PartialLog2Config

---@type java.Config
local config = {
	checks = {
		nvim_version = true,
		nvim_jdtls_conflict = true,
	},

	experimental = {
		fix_generated_sources = false,
	},

	jdtls = {
		version = JDTLS_VERSION,
		path = nil,
		auto_install = true,
	},

	lombok = {
		enable = true,
		version = V.lombok,
		path = nil,
		auto_install = true,
	},

	-- load java test plugins
	java_test = {
		enable = true,
		version = V.java_test,
		path = nil,
		auto_install = true,
	},

	-- load java debugger plugins
	java_debug_adapter = {
		enable = true,
		version = V.java_debug_adapter,
		path = nil,
		auto_install = true,
	},

	spring_boot_tools = {
		enable = true,
		version = V.spring_boot_tools,
		path = nil,
		auto_install = true,
	},

	jdk = {
		auto_install = true,
		version = V.jdk,
		path = nil,
	},

	log = {
		use_console = true,
		use_file = true,
		level = 'info',
		log_file = vim.fn.stdpath('state') .. '/nvim-java.log',
		max_lines = 1000,
		show_location = false,
	},
}

return config

```

## README.md

````text
# :coffee: nvim-java

![Spring](https://img.shields.io/badge/Spring-6DB33F?style=for-the-badge&logo=spring&logoColor=white)
![Java](https://img.shields.io/badge/java-%23ED8B00.svg?style=for-the-badge&logo=openjdk&logoColor=white)
![Gradle](https://img.shields.io/badge/Gradle-02303A.svg?style=for-the-badge&logo=Gradle&logoColor=white)
![Apache Maven](https://img.shields.io/badge/Apache%20Maven-C71A36?style=for-the-badge&logo=Apache%20Maven&logoColor=white)
![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
![Lua](https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows11&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)

---

Just install and start writing `public static void main(String[] args)`.

---

> [!TIP]
> You can find cool tips & tricks here https://github.com/nvim-java/nvim-java/wiki/Tips-&-Tricks

## :loudspeaker: Demo

<https://github.com/nvim-java/nvim-java/assets/18459807/047c8c46-9a0a-4869-b342-d5c2e15647bc>

## :dizzy: Features

- :white_check_mark: Spring Boot Tools
- :white_check_mark: Diagnostics & Auto Completion
- :white_check_mark: Automatic Debug Configuration
- :white_check_mark: Organize Imports & Code Formatting
- :white_check_mark: Running Tests
- :white_check_mark: Run & Debug Profiles
- :white_check_mark: Built-in Application Runner with Log Viewer
- :white_check_mark: Profile Management UI
- :white_check_mark: Decompiler Support
- :white_check_mark: [Code Actions](https://github.com/nvim-java/nvim-java/wiki/Tips-&-Tricks#running-code-actions)

## :hammer: How to Install

<details>

<summary>:small_orange_diamond:details</summary>

**Requirements:** Neovim 0.11.5+

### Using `vim.pack`

```lua
vim.pack.add({
  {
    src = 'https://github.com/JavaHello/spring-boot.nvim',
    version = '218c0c26c14d99feca778e4d13f5ec3e8b1b60f0',
  },
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/mfussenegger/nvim-dap',

  'https://github.com/nvim-java/nvim-java',
})

require('java').setup()
vim.lsp.enable('jdtls')
```

### Using `lazy.nvim`

Install using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'nvim-java/nvim-java',
  config = function()
    require('java').setup()
    vim.lsp.enable('jdtls')
  end,
}
```

Yep! That's all :)

</details>

## :keyboard: Commands

<details>

<summary>:small_orange_diamond:details</summary>

### Build

- `JavaBuildBuildWorkspace` - Runs a full workspace build

- `JavaBuildCleanWorkspace` - Clear the workspace cache
  (for now you have to close and reopen to restart the language server after
  the deletion)

### Runner

- `JavaRunnerRunMain` - Runs the application or selected main class (if there
  are multiple main classes)

```vim
:JavaRunnerRunMain
:JavaRunnerRunMain <arguments> <to> <pass>
```

- `JavaRunnerStopMain` - Stops the running application
- `JavaRunnerToggleLogs` - Toggle between show & hide runner log window

### DAP

- `JavaDapConfig` - DAP is autoconfigured on start up, but in case you want to
  force configure it again, you can use this API

### Test

- `JavaTestRunCurrentClass` - Run the test class in the active buffer
- `JavaTestDebugCurrentClass` - Debug the test class in the active buffer
- `JavaTestRunCurrentMethod` - Run the test method on the cursor
- `JavaTestDebugCurrentMethod` - Debug the test method on the cursor
- `JavaTestRunAllTests` - Run all tests in the workspace
- `JavaTestDebugAllTests` - Debug all tests in the workspace
- `JavaTestViewLastReport` - Open the last test report in a popup window

### Profiles

- `JavaProfile` - Opens the profiles UI

### Refactor

- `JavaRefactorExtractVariable` - Create a variable from value at cursor/selection
- `JavaRefactorExtractVariableAllOccurrence` - Create a variable for all
  occurrences from value at cursor/selection
- `JavaRefactorExtractConstant` - Create a constant from the value at cursor/selection
- `JavaRefactorExtractMethod` - Create a method from the value at cursor/selection
- `JavaRefactorExtractField` - Create a field from the value at cursor/selection

### Settings

- `JavaSettingsChangeRuntime` - Change the JDK version to another

</details>

## :computer: APIs

<details>

<summary>:small_orange_diamond:details</summary>

### Build

- `build.build_workspace` - Runs a full workspace build

```lua
require('java').build.build_workspace()
```

- `build.clean_workspace` - Clear the workspace cache
  (for now you have to close and reopen to restart the language server after
  the deletion)

```lua
require('java').build.clean_workspace()
```

### Runner

- `built_in.run_app` - Runs the application or selected main class (if there
  are multiple main classes)

```lua
require('java').runner.built_in.run_app({})
require('java').runner.built_in.run_app({'arguments', 'to', 'pass', 'to', 'main'})
```

- `built_in.stop_app` - Stops the running application

```lua
require('java').runner.built_in.stop_app()
```

- `built_in.toggle_logs` - Toggle between show & hide runner log window

```lua
require('java').runner.built_in.toggle_logs()
```

### DAP

- `config_dap` - DAP is autoconfigured on start up, but in case you want to force
  configure it again, you can use this API

```lua
require('java').dap.config_dap()
```

### Test

- `run_current_class` - Run the test class in the active buffer

```lua
require('java').test.run_current_class()
```

- `debug_current_class` - Debug the test class in the active buffer

```lua
require('java').test.debug_current_class()
```

- `run_current_method` - Run the test method on the cursor

```lua
require('java').test.run_current_method()
```

- `debug_current_method` - Debug the test method on the cursor

```lua
require('java').test.debug_current_method()
```

- `run_all_tests` - Run all tests in the workspace

```lua
require('java').test.run_all_tests()
```

- `debug_all_tests` - Debug all tests in the workspace

```lua
require('java').test.debug_all_tests()
```

- `view_report` - Open the last test report in a popup window

```lua
require('java').test.view_last_report()
```

### Profiles

```lua
require('java').profile.ui()
```

### Refactor

- `extract_variable` - Create a variable from value at cursor/selection

```lua
require('java').refactor.extract_variable()
```

- `extract_variable_all_occurrence` - Create a variable for all occurrences from
  value at cursor/selection

```lua
require('java').refactor.extract_variable_all_occurrence()
```

- `extract_constant` - Create a constant from the value at cursor/selection

```lua
require('java').refactor.extract_constant()
```

- `extract_method` - Create method from the value at cursor/selection

```lua
require('java').refactor.extract_method()
```

- `extract_field` - Create a field from the value at cursor/selection

```lua
require('java').refactor.extract_field()
```

### Settings

- `change_runtime` - Change the JDK version to another

```lua
require('java').settings.change_runtime()
```

</details>

## :clamp: How to Use JDK X.X Version?

<details>
  
<summary>:small_orange_diamond:details</summary>

Use `vim.lsp.config()` to override the default JDTLS settings:

```lua
vim.lsp.config('jdtls', {
  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = "JavaSE-21",
            path = "/opt/jdk-21",
            default = true,
          }
        }
      }
    }
  }
})
```

</details>

## :wrench: Configuration

<details>

<summary>:small_orange_diamond:details</summary>

For most users changing the default configuration is not necessary. But if you
want, following options are available:

```lua
require('java').setup({
  -- Startup checks
  checks = {
    nvim_version = true,        -- Check Neovim version
    nvim_jdtls_conflict = true, -- Check for nvim-jdtls conflict
  },

  -- JDTLS configuration
  jdtls = {
    version = '1.43.0',
    path = nil,
    auto_install = true,
  },

  -- Extensions
  lombok = {
    enable = true,
    version = '1.18.40',
    path = nil,
    auto_install = true,
  },

  java_test = {
    enable = true,
    version = '0.40.1',
    path = nil,
    auto_install = true,
  },

  java_debug_adapter = {
    enable = true,
    version = '0.58.2',
    path = nil,
    auto_install = true,
  },

  spring_boot_tools = {
    enable = true,
    version = '1.55.1',
    path = nil,
    auto_install = true,
  },

  -- JDK installation
  jdk = {
    auto_install = true,
    version = '17',
    path = nil,
  },

  -- Logging
  log = {
    use_console = true,
    use_file = true,
    level = 'info',
    log_file = vim.fn.stdpath('state') .. '/nvim-java.log',
    max_lines = 1000,
    show_location = false,
  },
})
```

Set `path` when a tool is managed externally. When `path` is set, nvim-java
uses that path and does not install the tool. Set
`auto_install = false` on a tool to fail instead of downloading when no path is
configured. Note: `path` has no effect when the tool is disabled
(`enable = false`) — the tool is simply not loaded.

Path meanings:

- `jdtls.path`: directory containing `plugins/` and platform `config_*`
  directories
- `lombok.path`: path to `lombok.jar`
- `java_test.path`, `java_debug_adapter.path`, `spring_boot_tools.path`: VS Code
  extension root containing `package.json`
- `jdk.path`: JDK home containing `bin/java`

</details>

## :golf: Architecture

<details>

<summary>:small_orange_diamond:details</summary>

Following is the high level idea. Jdtls is the language server nvim-java
communicates with. However, we don't have all the features we need just in
Jdtls. So, we are loading java-test & java-debug-adapter extensions when we
launch Jdtls. Once the language server is started, we communicate with the
language server to do stuff.

For instance, to run the current test,

- Request Jdtls for test classes
- Request Jdtls for class paths, module paths, java executable
- Request Jdtls to start a debug session and send the port of the session back
- Prepare TCP connections to listen to the test results
- Start nvim-dap and let user interactions to be handled by nvim-dap
- Parse the test results as they come in
- Once the execution is done, open a window show the test results

```text
  ┌────────────┐                         ┌────────────┐
  │            │                         │            │
  │   Neovim   │                         │   VSCode   │
  │            │                         │            │
  └─────▲──────┘                         └──────▲─────┘
        │                                       │
        │                                       │
        │                                       │
        │                                       │
┌───────▼───────┐                ┌──────────────▼──────────────┐
│               │                │                             │
│   nvim-java   │                │   Extension Pack for Java   │
│               │                │                             │
└───────▲───────┘                └──────────────▲──────────────┘
        │                                       │
        │                                       │
        │                                       │
        │                                       │
        │                                       │
        │              ┌───────────┐            │
        │              │           │            │
        └──────────────►   JDTLS   ◄────────────┘
                       │           │
                       └───▲───▲───┘
                           │   │
                           │   │
                           │   │
                           │   │
                           │   │
  ┌───────────────┐        │   │         ┌────────────────────────┐
  │               │        │   │         │                        │
  │   java-test   ◄────────┘   └─────────►   java-debug-adapter   │
  │               │                      │                        │
  └───────────────┘                      └────────────────────────┘
```

</details>

## :bookmark_tabs: Projects Acknowledgement

- [spring-boot.nvim](https://github.com/JavaHello/spring-boot.nvim) is the one
  that starts sts4 & do other necessary `jdtls` `sts4` sync command registration
  in `nvim-java`.

- [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls) is a plugin that follows
  "Keep it simple, stupid!" approach. If you love customizing things by yourself,
  then give nvim-jdtls a try.

````

## LICENSE

```text
MIT License

Copyright (c) 2024 s1n7ax

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
