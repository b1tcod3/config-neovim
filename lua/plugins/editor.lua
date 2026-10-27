return {
    -- Pares automáticos
    {
        "nvim-mini/mini.pairs",
        lazy = false,
        config = function()
            require("mini.pairs").setup()
        end,
    },

    -- Cierre automático de etiquetas HTML
    {
        "windwp/nvim-ts-autotag",
        ft = {
            "html",
            "php",
            "blade",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "astro",
            "vue",
            "svelte",
            "xml",
        },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-ts-autotag").setup({
                opts = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = false,
                },
            })
        end,
    },

    -- Code folding
    {
        "kevinhwang91/nvim-ufo",
        dependencies = "kevinhwang91/promise-async",
        event = "VeryLazy",
        config = function()
            require("ufo").setup({
                close_fold_kinds = {},
                provider_selector = function()
                    return { "treesitter", "indent" }
                end,
                fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
                    local newVirtText = {}
                    local suffix = (" 󰁂 %d "):format(endLnum - lnum)
                    local targetWidth = width - vim.fn.strdisplaywidth(suffix)
                    local curWidth = 0

                    for _, chunk in ipairs(virtText) do
                        local chunkText = chunk[1]
                        local chunkWidth = vim.fn.strdisplaywidth(chunkText)

                        if curWidth + chunkWidth < targetWidth then
                            table.insert(newVirtText, chunk)
                            curWidth = curWidth + chunkWidth
                        else
                            local remaining = targetWidth - curWidth
                            if remaining > 0 then
                                table.insert(newVirtText, { truncate(chunkText, remaining), chunk[2] })
                            end
                            break
                        end
                    end

                    table.insert(newVirtText, { suffix, "MoreMsg" })
                    return newVirtText
                end,
            })
        end,
    },

    -- Comentarios
    {
        "numToStr/Comment.nvim",
        keys = { "gc", "gbc" },
        config = function()
            require("Comment").setup()
        end,
    },

    -- GitHub Copilot
    {
        "github/copilot.vim",
        event = "InsertEnter",
        cmd = "Copilot",
        init = function()
            vim.g.copilot_no_tab_map = true
        end,
    },

    -- Alineación y navegación
    { "junegunn/vim-easy-align" },
    { url = "https://codeberg.org/andyg/leap.nvim" },

    -- Extras
    { "ThePrimeagen/vim-be-good", cmd = "VimBeGood" },
    { "slint-ui/vim-slint", ft = "slint" },

    -- Buscador
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    file_ignore_patterns = { "node_modules", ".git", "dist", "build" },
                },
            })
        end,
    },
}
