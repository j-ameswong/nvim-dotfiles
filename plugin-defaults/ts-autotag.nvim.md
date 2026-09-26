# ts-autotag.nvim defaults and configuration source

Commit: `6178353d9003e91eb053d69cf9a4d72e28137daa`

These are the upstream configuration sources at the locked commit. Defaults defined in code are reproduced verbatim; documentation is included for plugins whose settings are not expressed as one Lua table.

## lua/ts-autotag/config.lua

```lua
local M = {}

---@return boolean
function M.is_disabled_executing_macro()
    return M.config.disable_in_macro and (vim.fn.reg_recording() ~= "" or vim.fn.reg_executing() ~= "")
end

---@type TsAutotag.Config
M.config = {
    opening_node_types = {
        -- templ
        "tag_start",

        -- xml,
        "STag",

        -- html
        "start_tag",

        -- jsx
        "jsx_opening_element",
    },
    identifier_node_types = {
        -- html
        "tag_name",
        "erroneous_end_tag_name",

        -- xml,
        "Name",

        -- jsx
        "member_expression",
        "identifier",

        -- templ
        "element_identifier",
    },

    filetypes = {
        "typescript",
        "javascript",
        "typescriptreact",
        "javascriptreact",
        "xml",
        "html",
        "templ",
        "php",
    },

    disable_in_macro = true,

    auto_close = {
        enabled = true,
    },
    auto_rename = {
        enabled = false,
        closing_node_types = {
            -- jsx
            "jsx_closing_element",

            -- xml,
            "ETag",

            -- html
            "end_tag",
            "erroneous_end_tag",

            -- templ
            "tag_end",
        },
    },

    should_attach = function()
        return true
    end,
}

return M

```

## LICENSE

```text
MIT License

Copyright (c) 2024 Donatas

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
