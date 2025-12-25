return {
    {
        "mason-org/mason.nvim",
        opts = {}
    },
    {
      'nvim-java/nvim-java',
      config = function()
        require('java').setup()
        vim.lsp.enable('jdtls')
      end,
    }
}
