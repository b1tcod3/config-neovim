local parsers = {
    "c",
    "lua",
    "vim",
    "vimdoc",
    "query",
    "php",
    "html",
    "css",
    "javascript",
    "typescript",
    "rust",
    "python",
    "astro",
    "go",
    "markdown",
    "markdown_inline",
    "blade",
}

return {
    -- Treesitter (rama main: no soporta lazy-loading)
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local installed = require("nvim-treesitter.config").get_installed("parsers")
            local installed_set = {}
            for _, parser in ipairs(installed) do
                installed_set[parser] = true
            end

            local missing = vim.tbl_filter(function(parser)
                return not installed_set[parser]
            end, parsers)

            if #missing > 0 then
                require("nvim-treesitter").install(missing)
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
                callback = function(args)
                    if vim.bo[args.buf].buftype ~= "" then
                        return
                    end

                    local ok = pcall(vim.treesitter.start, args.buf)
                    if ok then
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },

    -- Navegación por funciones y clases
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        lazy = true,
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-treesitter-textobjects").setup({
                move = { set_jumps = true },
            })
        end,
    },
}
