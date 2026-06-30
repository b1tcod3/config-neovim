return {
    -- TEMA
    { "folke/tokyonight.nvim", lazy = false, priority = 1000, config = function() vim.cmd([[colorscheme tokyonight]]) end },

    -- UI MODERNA
    { "folke/noice.nvim", event = "VeryLazy", opts = {
        presets = { bottom_search = true, command_palette = true },
        routes = {
            { filter = { event = "msg_showmode" }, view = "notify" },
        },
    } },

    -- TODO COMMENTS
    { "folke/todo-comments.nvim", dependencies = "nvim-lspconfig", event = "VeryLazy", opts = {} },

    -- PARES AUTOMÁTICOS
    { "nvim-mini/mini.pairs", lazy = false, config = function() require("mini.pairs").setup() end },

    -- CIERRE AUTOMÁTICO DE ETIQUETAS HTML
    { "windwp/nvim-ts-autotag", dependencies = "nvim-treesitter", event = "InsertEnter *.html,*.php,*.blade", config = function()
        require("nvim-ts-autotag").setup({
            enable_close = true,
            enable_fold = false,
        })
    end },

    -- CODE FOLDING
    { "kevinhwang91/nvim-ufo", dependencies = "kevinhwang91/promise-async", event = "VeryLazy", config = function()
        require("ufo").setup({
            close_fold_kinds = {},
            provider_selector = function(bufnr, filetype, buftype)
                return {"treesitter", "indent"}
            end,
            fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
                local newVirtText = {}
                local suffix = (" 󰁂 %d "):format(endLnum - lnum)
                local sufWidth = vim.fn.strdisplaywidth(suffix)
                local targetWidth = width - sufWidth
                local curWidth = 0
                for _, chunk in ipairs(virtText) do
                    local chunkText = chunk[1]
                    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if targetWidth - curWidth - chunkWidth > 0 then
                        table.insert(newVirtText, chunk)
                    else
                        chunkText = truncate(chunkText, targetWidth - curWidth - 4)
                        if chunkText:match(".*[..]") then
                            chunkText = chunkText .. "..."
                        else
                            chunkText = chunkText .. " "
                        end
                        table.insert(newVirtText, {chunkText, chunk[2]})
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end
                table.insert(newVirtText, {suffix, "MoreMsg"})
                return newVirtText
            end
        })
        vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter", "FileType" }, {
            pattern = "*",
            callback = function()
                vim.defer_fn(function()
                    require("ufo").openAllFolds()
                end, 100)
            end,
        })
        vim.opt.foldlevel = 20
        vim.keymap.set("n", "zR", require("ufo").openAllFolds)
        vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
        vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
        vim.keymap.set("n", "zm", require("ufo").closeFoldsWith)
    end },

    -- BARRA DE ESTADO (Reemplaza a Airline)
    { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, config = function() require('lualine').setup() end },

    -- BUFFERS (Reemplaza a Airline/tabs)
    { "akinsho/bufferline.nvim", version = "*", dependencies = "nvim-web-devicons", config = function()
        require("bufferline").setup({ options = { offsets = { { filetype = "NvimTree", text = "", highlight = "Directory" } } } })
    end },

    -- EXPLORADOR DE ARCHIVOS
    { "nvim-tree/nvim-tree.lua", dependencies = "nvim-web-devicons", config = function()
        require("nvim-tree").setup({ git = { ignore = false } })
    end },

    -- NAVEGADOR DE SÍMBOLOS (Aerial)
    { "stevearc/aerial.nvim", dependencies = "nvim-web-devicons", event = "VeryLazy", config = function()
        require("aerial").setup({
            attach_mode = "global",
            backends = { "treesitter", "lsp" },
            layout = { min_width = 40 },
            show_bar = true,
        })
    end },

    -- COMENTARIOS
    { "numToStr/Comment.nvim", keys = {"gc", "gbc"}, config = function() require("Comment").setup() end },

    -- TUS PLUGINS DE SIEMPRE
    { "github/copilot.vim" },
    { "junegunn/vim-easy-align" },
    { "ggandor/leap.nvim" },
    { "ThePrimeagen/vim-be-good" },

    -- SURROUND (pares, comillas, etc.)
    { "nvim-mini/mini.surround", lazy = false, config = function()
        require("mini.surround").setup()
    end },

    { "rust-lang/rust.vim", init = function()
        vim.g.rustfmt_autosave = 1
    end },
    { "slint-ui/vim-slint" },
    { "dart-lang/dart-vim-plugin" },
    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "php", "html", "css", "javascript", "typescript", "rust", "python", "astro" },
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },

    -- BUSCADOR (Telescope)
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" }, config = function()
        require('telescope').setup({
            defaults = {
                file_ignore_patterns = { "node_modules", ".git", "dist", "build" }
            }
        })
    end },

    -- LSP Y AUTOCOMPLETADO (Nativo v0.11+)
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "saghen/blink.cmp",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "rust_analyzer", "intelephense", "pyright", "lua_ls", "tailwindcss", "astro", "emmet_ls", "html" }
            })

            local capabilities = require("blink.cmp").get_lsp_capabilities()

            vim.lsp.config("intelephense", {
                capabilities = capabilities,
            })
            vim.lsp.config("pyright", {
                capabilities = capabilities,
            })
            vim.lsp.config("rust_analyzer", {
                capabilities = capabilities,
            })
            vim.lsp.config("lua_ls", {
                capabilities = capabilities,
            })
            vim.lsp.config("tailwindcss", {
                capabilities = capabilities,
            })
            vim.lsp.config("astro", {
                capabilities = capabilities,
            })
            vim.lsp.config("emmet_ls", {
                capabilities = capabilities,
            })
            vim.lsp.config("html", {
                capabilities = capabilities,
            })

            vim.lsp.enable("intelephense")
            vim.lsp.enable("pyright")
            vim.lsp.enable("rust_analyzer")
            vim.lsp.enable("lua_ls")
            vim.lsp.enable("tailwindcss")
            vim.lsp.enable("astro")
            vim.lsp.enable("emmet_ls")
            vim.lsp.enable("html")
        end
    },

    -- Blink.cmp (autocompletado)
    {
        "saghen/blink.cmp",
        version = "*",
        dependencies = { "nvim-lspconfig" },
        opts = {
            keymap = {
                preset = "enter",
                ["<Tab>"] = { "select_next", "fallback" },
                ["<S-Tab>"] = { "select_prev", "fallback" },
            },
            sources = {
                default = { "lsp", "snippets", "buffer" },
            },
        },
    },

    -- Conform.nvim (formateo, deshabilitado por rendimiento)
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            formatters_by_ft = {
                blade = { "blade-formatter" },
            },
            format_on_save = {
                timeout_ms = 3000,
                lsp_fallback = true,
            },
            notify_on_error = true,
        },
        enabled = false,
    },
}
