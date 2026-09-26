-- Locked defaults: ../../../plugin-defaults/undotree.md @ 5721c3fb3876f3e772251a23d1ab0948899a0216
return {
	"jiaoshijie/undotree",
	---@module 'undotree.collector'
	---@type UndoTreeCollector.Opts
	opts = {
        position = "right",
	},
	keys = { -- load the plugin only when using it's keybinding:
		{ "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
	},
}
