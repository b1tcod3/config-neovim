return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    build = ":TSInstall markdown markdown_inline",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
}
