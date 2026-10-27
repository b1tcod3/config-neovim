return {
    -- Tema
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("tokyonight")
        end,
    },

    -- UI moderna
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = { "MunifTanjim/nui.nvim" },
        opts = {
            presets = { bottom_search = true, command_palette = true },
            routes = {
                { filter = { event = "msg_showmode" }, view = "notify" },
            },
        },
    },

    -- TODO comments
    {
        "folke/todo-comments.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },

    -- Barra de estado
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup()
        end,
    },

    -- Buffers
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-web-devicons",
        config = function()
            require("bufferline").setup({
                options = {
                    offsets = {
                        { filetype = "NvimTree", text = "", highlight = "Directory" },
                    },
                },
            })
        end,
    },

    -- Explorador de archivos
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = "nvim-web-devicons",
        cmd = {
            "NvimTreeToggle",
            "NvimTreeOpen",
            "NvimTreeFocus",
            "NvimTreeFindFile",
            "NvimTreeCollapse",
        },
        keys = {
            { "<leader>e", "<Cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
        },
        config = function()
            require("nvim-tree").setup({
                git = { ignore = false },
            })
        end,
    },

    -- Navegador de símbolos
    {
        "stevearc/aerial.nvim",
        dependencies = "nvim-web-devicons",
        event = "VeryLazy",
        cmd = "AerialToggle",
        keys = {
            {
                "<leader>ao",
                function()
                    require("aerial").toggle({ focus = true, direction = "right" })
                end,
                desc = "Toggle Aerial",
            },
        },
        config = function()
            require("aerial").setup({
                attach_mode = "global",
                backends = { "treesitter", "lsp" },
                layout = { min_width = 40 },
                show_bar = true,
            })
        end,
    },
}
