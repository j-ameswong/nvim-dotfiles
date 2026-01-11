-- For `plugins/markview.lua` users.
return {
	"OXY2DEV/markview.nvim",
	lazy = false,

	-- Completion for `blink.cmp`
	dependencies = { "saghen/blink.cmp" },
	opts = {
		markdown_inline = {
			-- 'strong' refers to bold text (**)
			strong = {
				enable = true,
				-- This links the bold text to a specific highlight group
				hl = "MarkviewBoldCustom",
			},
		},
	},
}
