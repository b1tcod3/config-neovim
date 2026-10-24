return {
    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.config").setup({
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "php", "html", "css", "javascript", "typescript", "rust", "python", "astro", "go", "markdown", "markdown_inline", "blade" },
                sync_install = false,
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*",
                callback = function()
                    local ok = pcall(vim.treesitter.start)
                    if ok then
                        pcall(function()
                            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                        end)
                    end
                end,
            })
        end
    },

    { "nvim-treesitter/nvim-treesitter-textobjects", config = function()
        require("nvim-treesitter.config").setup({
            textobjects = {
                move = {
                    enable = true,
                    set_jumps = true,
                    -- Saltos a los INICIOS
                    goto_next_start = {
                        ["]m"] = "@function.outer", -- Siguiente inicio de función
                        ["]c"] = "@class.outer",    -- Siguiente inicio de clase (¡Usaremos ]c!)
                    },
                    goto_previous_start = {
                        ["[m"] = "@function.outer", -- Inicio de función anterior
                        ["[c"] = "@class.outer",    -- Inicio de clase anterior
                    },
                    -- Saltos a los FINALES
                    goto_next_end = {
                        ["]M"] = "@function.outer", -- Siguiente fin de función (Por eso aterrizabas al final del index)
                        ["]C"] = "@class.outer",    -- Siguiente fin de clase
                    },
                    goto_previous_end = {
                        ["[M"] = "@function.outer", -- Fin de función anterior
                        ["[C"] = "@class.outer",    -- Fin de clase anterior
                    },
                },
            },
        })

        local move = require("nvim-treesitter-textobjects.move")
        local modes = { "n", "x", "o" }
        vim.keymap.set(modes, "]m", function() move.goto_next_start("@function.outer") end)
        vim.keymap.set(modes, "[m", function() move.goto_previous_start("@function.outer") end)
        vim.keymap.set(modes, "]M", function() move.goto_next_end("@function.outer") end)
        vim.keymap.set(modes, "[M", function() move.goto_previous_end("@function.outer") end)
        vim.keymap.set(modes, "]c", function() move.goto_next_start("@class.outer") end)
        vim.keymap.set(modes, "[c", function() move.goto_previous_start("@class.outer") end)
        vim.keymap.set(modes, "]C", function() move.goto_next_end("@class.outer") end)
        vim.keymap.set(modes, "[C", function() move.goto_previous_end("@class.outer") end)
    end },
}
