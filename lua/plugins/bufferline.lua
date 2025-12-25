return {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
        require("bufferline").setup{}
    end,
    keys = {
        -- Navigate buffers (Shift + h/l)
        { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
        { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },

        -- Re-order buffers (Alt + h/l) (Optional)
        { "<A-h>", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
        { "<A-l>", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
    },
}
