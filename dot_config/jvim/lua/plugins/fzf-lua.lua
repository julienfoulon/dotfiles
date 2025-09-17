return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
        -- lazy load the plugin on these key mappings
        {
            "<leader>sf", 
            function() require('fzf-lua').files() end,
            desc = "Search File in project directory"
        },
        {
            "<leader>st",
            function() require('fzf-lua').live_grep() end,
            desc = "Search Text in project files"

        },
        {
            "<leader>sa",
            function() require('fzf-lua').builtin() end,
            desc = "Search list of fzf-lua options"

        },

    }
}
