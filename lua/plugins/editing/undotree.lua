-- Locked defaults: ../../../plugin-defaults/undotree.md @ ae312c61558ee41316e992d3bae3afea2a77f62c
return {
	"jiaoshijie/undotree",
	enabled = true,
	---@module 'undotree.collector'
	---@type UndoTreeCollector.Opts
	opts = {
        position = "right",
	},
	keys = { -- load the plugin only when using it's keybinding:
		{ "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
	},
}
