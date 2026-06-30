local keymap = vim.keymap

-- Guardado
keymap.set("n", "<leader>w", ":w<CR>", { desc = "Guardar archivo" })
keymap.set("n", "<leader>wa", ":wa<CR>", { desc = "Guardar todos" })
keymap.set("n", "<leader>wq", ":wq<CR>", { desc = "Guardar y salir" })
keymap.set("n", "<leader>qq", ":q<CR>", { desc = "Salir" })
keymap.set("n", "<leader>q!", ":q!<CR>", { desc = "Forzar salida" })

-- Ctrl+s (normal y insert)
keymap.set("n", "<C-s>", ":w<CR>", { desc = "Guardar" })
keymap.set("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Guardar y permanecer en insert" })

-- Toggle mini.pairs (desactivar paréntesis automático)
local pairs_enabled = true
keymap.set("n", "<leader>tp", function()
    if pairs_enabled then
        vim.g.minipairs_disable = true
        pairs_enabled = false
        print("mini.pairs DESACTIVADO")
    else
        vim.g.minipairs_disable = false
        pairs_enabled = true
        print("mini.pairs ACTIVADO")
    end
end, { desc = "Toggle auto-pairs" })

keymap.set("n", "<leader>ff", function() require('telescope.builtin').find_files() end, { desc = "Buscar archivos" })
keymap.set("n", "<leader>fg", function() require('telescope.builtin').live_grep() end, { desc = "Buscar contenido" })
keymap.set("n", "<leader>fb", function() require('telescope.builtin').buffers() end, { desc = "Buscar buffers" })
keymap.set("n", "<leader>fh", function() require('telescope.builtin').help_tags() end, { desc = "Buscar ayuda" })

-- Navegación LSP
keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Ir a definición" })
keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Ir a referencias" })
keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Ir a implementación" })
keymap.set("n", "gy", vim.lsp.buf.type_definition, { desc = "Ir a definición de tipo" })
keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Mostrar documentación" })
keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Renombrar símbolo" })
keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action / Importar clase" })
-- General
keymap.set("n", "<leader>e", ":Lex 25<CR>")
keymap.set("n", "<leader>nt", ":NvimTreeToggle<CR>", { desc = "Toggle explorer" })

-- Navegación entre pestañas
keymap.set("n", "<A-n>", ":tabnext<CR>", { desc = "Tab siguiente" })
keymap.set("n", "<A-p>", ":tabprevious<CR>", { desc = "Tab anterior" })

-- Navegación entre buffers
keymap.set("n", "<C-n>", ":bnext<CR>", { desc = "Buffer siguiente" })
keymap.set("n", "<C-p>", ":bprevious<CR>", { desc = "Buffer anterior" })
keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Buffer siguiente" })
keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Buffer anterior" })
keymap.set("n", "<leader>wd", ":bdelete<CR>", { desc = "Cerrar buffer" })
keymap.set("n", "<Leader><PageUp>", ":bprevious<CR>", { desc = "Buffer anterior" })
keymap.set("n", "<Leader><PageDown>", ":bnext<CR>", { desc = "Buffer siguiente" })

-- Todo Comments
keymap.set("n", "<leader>tt", ":TodoTelescope<CR>", { desc = "Buscar todos" })
keymap.set("n", "]t", function() require("todo-comments.jump").next() end, { desc = "Todo siguiente" })
keymap.set("n", "[t", function() require("todo-comments.jump").prev() end, { desc = "Todo anterior" })

-- Folding (Ufo)
keymap.set("n", "zR", function() require("ufo").openAllFolds() end, { desc = "Abrir todos los folds" })
keymap.set("n", "zM", function() require("ufo").closeAllFolds() end, { desc = "Cerrar todos los folds" })
keymap.set("n", "zr", function() require("ufo").openFoldsExceptKinds() end, { desc = "Abrir folds excepto funciones" })
keymap.set("n", "zm", function() require("ufo").closeFoldsWith() end, { desc = "Cerrar folds con" })
keymap.set("n", "zk", function() require("ufo").goPreviousClosedFold() end, { desc = "Fold anterior" })
keymap.set("n", "zj", function() require("ufo").goNextClosedFold() end, { desc = "Fold siguiente" })

-- Aerial (navegador de símbolos)
keymap.set("n", "<leader>ao", ":AerialToggle! right<CR>", { desc = "Toggle Aerial" })

-- Leap (navegación rápida)
keymap.set({ "n", "x", "o" }, "<Leader>s", "<Plug>(leap-forward)", { desc = "Leap forward" })
keymap.set({ "n", "x", "o" }, "<Leader>S", "<Plug>(leap-backward)", { desc = "Leap backward" })

-- EasyAlign (alinear código)
keymap.set("n", "ga", "<Plug>(EasyAlign)")
keymap.set("x", "ga", "<Plug>(EasyAlign)")

-- Comentarios
keymap.set("n", "<leader>cc", function() require("Comment.api").toggle.linewise.current() end, { desc = "Comentar línea" })
keymap.set("n", "<leader>cb", function() require("Comment.api").toggle.blockwise.current() end, { desc = "Comentar bloque" })
keymap.set("v", "<leader>c", ":Commentary<CR>", { desc = "Comentar selección" })
