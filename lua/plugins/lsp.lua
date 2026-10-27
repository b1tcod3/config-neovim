return {
    -- Gestor de servidores LSP
    {
        "williamboman/mason.nvim",
        cmd = {
            "Mason",
            "MasonInstall",
            "MasonUninstall",
            "MasonUninstallAll",
            "MasonUpdate",
            "MasonLog",
        },
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = true,
        dependencies = { "williamboman/mason.nvim" },
    },

    -- LSP nativo (Neovim 0.11+)
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "saghen/blink.cmp",
        },
        config = function()
            vim.diagnostic.config({
                virtual_text = { spacing = 2, source = "if_many" },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = { border = "rounded", source = true },
            })

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "rust_analyzer",
                    "intelephense",
                    "pyright",
                    "lua_ls",
                    "tailwindcss",
                    "astro",
                    "emmet_ls",
                    "html",
                    "gopls",
                },
            })

            vim.lsp.config("*", {
                capabilities = require("blink.cmp").get_lsp_capabilities(),
            })

            vim.lsp.enable({
                "intelephense",
                "pyright",
                "rust_analyzer",
                "lua_ls",
                "tailwindcss",
                "astro",
                "emmet_ls",
                "html",
                "gopls",
            })
        end,
    },

    -- Autocompletado
    {
        "saghen/blink.cmp",
        version = "*",
        event = { "InsertEnter", "BufReadPre", "BufNewFile" },
        opts = {
            keymap = {
                preset = "enter",
                ["<Tab>"] = { "select_next", "fallback" },
                ["<S-Tab>"] = { "select_prev", "fallback" },
            },
            sources = {
                default = { "lsp", "snippets", "buffer" },
            },
            snippets = {
                -- vim.snippet: no requiere LuaSnip
                preset = "default",
            },
        },
    },
}
