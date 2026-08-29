return {
    "AlexandrosAlexiou/kotlin.nvim",
    ft = { "kotlin" },
    dependencies = {
        "mason.nvim",
        "mason-lspconfig.nvim",
        -- "oil.nvim",
        -- "trouble.nvim",
        -- nvim-dap is NOT a kotlin.nvim dependency. Install and configure it
        -- separately (signs, keymaps, optionally nvim-dap-ui). kotlin.nvim only
        -- registers a `kotlin` adapter and the `:KotlinDebug` command on top.
        -- See the "Debugging Support" section below for details.
    },
    config = function()
        -- kotlin.nvim looks for the server in $MASON/packages/kotlin-lsp first,
        -- then falls back to $KOTLIN_LSP_DIR. Mason's kotlin-lsp download is
        -- broken upstream (JetBrains 404s every kotlin-server tarball), so the
        -- server is installed manually from the VS Code Marketplace VSIX.
        -- To reinstall/upgrade (VSIX is ~384MB, contains its own JBR):
        --   curl -sSL -H "Accept-Encoding: gzip" -o k.gz \
        --     "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/JetBrains/vsextensions/kotlin-server/<ver>/vspackage?targetPlatform=linux-x64"
        --   gunzip -c k.gz > k.vsix && unzip -q k.vsix "extension/server/*" -d x
        --   rm -rf ~/.local/share/kotlin-lsp && mkdir -p ~/.local/share/kotlin-lsp
        --   mv x/extension/server/* ~/.local/share/kotlin-lsp/
        --   chmod +x ~/.local/share/kotlin-lsp/bin/intellij-server
        -- Switch back to Mason (once JetBrains restores downloads) by deleting
        -- this line and running :MasonInstall kotlin-lsp.
        vim.env.KOTLIN_LSP_DIR = vim.fn.expand("~/.local/share/kotlin-lsp")

        require("kotlin").setup {
            -- Optional: Specify root markers for multi-module projects
            -- Default: { "build.gradle", "build.gradle.kts", "pom.xml", "mvnw" }
            root_markers = {
                "gradlew",
                ".git",
                "mvnw",
                "settings.gradle",
            },

            -- Optional: JDK for symbol resolution (analyzing your Kotlin code)
            -- This is the JDK that your project code will be analyzed against
            -- (the server itself runs on bin/intellij-server's bundled JBR)
            -- Required for: Analyzing JDK APIs, standard library symbols, platform types
            --
            -- Usually should match your project's target JDK version
            -- Examples:
            --   macOS:   "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"
            --   Linux:   "/usr/lib/jvm/java-17-openjdk"
            --   Windows: "C:\\Program Files\\Java\\jdk-17"
            --   SDKMAN:  os.getenv("HOME") .. "/.sdkman/candidates/java/17.0.8-tem"
            -- Pinned to the project's Gradle toolchain (JavaLanguageVersion.of(25)).
            -- This is only the JDK your code is analyzed against; the server itself
            -- runs on the JBR bundled with kotlin-lsp, independent of $PATH/JAVA_HOME.
            jdk_for_symbol_resolution = "/usr/lib/jvm/java-25-openjdk",

            -- Optional: Specify additional JVM arguments for the kotlin-lsp server
            jvm_args = {
                "-Xmx4g",  -- Increase max heap (useful for large projects)
            },

            -- Optional: Configure inlay hints (requires kotlin-lsp v261+)
            -- All settings default to true, set to false to disable specific hints
            inlay_hints = {
                enabled = true,  -- Enable inlay hints (auto-enable on LSP attach)
                parameters = true,  -- Show parameter names
                parameters_compiled = true,  -- Show compiled parameter names
                parameters_excluded = false,  -- Show excluded parameter names
                parameters_context = false,  -- Show context parameter hints
                types_property = true,  -- Show property types
                types_variable = true,  -- Show local variable types
                function_return = true,  -- Show function return types
                function_parameter = true,  -- Show function parameter types
                lambda_return = true,  -- Show lambda return types
                lambda_receivers_parameters = true,  -- Show lambda receivers/parameters
                value_ranges = true,  -- Show value ranges
                kotlin_time = true,  -- Show kotlin.time warnings
                call_chains = false,  -- Show call-chain intermediate types (default false)
            },

            -- Optional: LSP-driven folding (requires kotlin-lsp v262.4739.0+)
            -- Enabled by default; set folding.enabled = false to opt out.
            folding = { enabled = true },

            -- Optional: build-importer preference (requires kotlin-lsp v262.4739.0+)
            -- Mirrors the VSCode `intellij.buildTool` setting:
            --   nil = let the server pick (default)
            --   "gradle" or "maven" = force a specific importer
            --   ""    = none (single-file / no build system)
            -- build_tool = "gradle",

            -- Optional: file templates for new Kotlin files (requires kotlin-lsp v262.4739.0+)
            -- When you create a new .kt file the plugin asks the server to interpolate the
            -- chosen template. Pass a table of name → Velocity template to override the
            -- defaults (Class, File, Interface, Data Class, Enum, Annotation, Object).
            -- Set { enabled = false } on the table to disable the prompt entirely.
            -- file_templates = {
            --     enabled = true,
            --     -- Class = "package ${PACKAGE_NAME}\n\nclass ${NAME} {\n\t|\n}",
            -- },
        }
    end,
}
