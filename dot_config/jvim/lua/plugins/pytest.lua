return {
    "richardhapb/pytest.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {}, -- Define the options here
    config = function(_, opts)
        require('pytest').setup(opts)
    end
}
