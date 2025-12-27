return {
	"mbbill/undotree",

    opts = {
        position = right,
    },
    keymaps = {
		vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
    }
}
