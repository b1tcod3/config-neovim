local keymap = vim.keymap

-- Guardado
keymap.set("n", "<leader>w", "<Cmd>w<CR>", { desc = "Guardar archivo", silent = true })
keymap.set("n", "<leader>wa", "<Cmd>wa<CR>", { desc = "Guardar todos", silent = true })
keymap.set("n", "<leader>wq", "<Cmd>wq<CR>", { desc = "Guardar y salir", silent = true })
keymap.set("n", "<leader>qq", "<Cmd>q<CR>", { desc = "Salir", silent = true })
keymap.set("n", "<leader>q!", "<Cmd>q!<CR>", { desc = "Forzar salida", silent = true })

-- Ctrl+s (normal e insert, sin salir del modo insert)
keymap.set("n", "<C-s>", "<Cmd>w<CR>", { desc = "Guardar", silent = true })
keymap.set("i", "<C-s>", "<Cmd>w<CR>", { desc = "Guardar y permanecer en insert", silent = true })

-- Aceptar sugerencia de Copilot (Tab queda libre para blink.cmp)
keymap.set("i", "<C-j>", 'copilot#Accept("\\<CR>")', {
  expr = true,
  silent = true,
  replace_keycodes = false,
  desc = "Aceptar sugerencia Copilot",
})

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

-- Telescope
keymap.set("n", "<leader>ff", function() require("telescope.builtin").find_files() end, { desc = "Buscar archivos" })
keymap.set("n", "<leader>fg", function() require("telescope.builtin").live_grep() end, { desc = "Buscar contenido" })
keymap.set("n", "<leader>fb", function() require("telescope.builtin").buffers() end, { desc = "Buscar buffers" })
keymap.set("n", "<leader>fh", function() require("telescope.builtin").help_tags() end, { desc = "Buscar ayuda" })

-- Navegación LSP (solo en buffers con cliente LSP)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
  callback = function(args)
    local buf = args.buf
    local function map(mode, lhs, rhs, desc)
      keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    map("n", "gd", vim.lsp.buf.definition, "Ir a definición")
    map("n", "gr", vim.lsp.buf.references, "Ir a referencias")
    map("n", "gi", vim.lsp.buf.implementation, "Ir a implementación")
    map("n", "gy", vim.lsp.buf.type_definition, "Ir a definición de tipo")
    map("n", "K", vim.lsp.buf.hover, "Mostrar documentación")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Renombrar símbolo")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action / Importar clase")
  end,
})

-- Navegación por funciones/clases (carga perezosa de textobjects)
local function ts_move(method, capture)
  return function()
    require("nvim-treesitter-textobjects.move")[method](capture)
  end
end

local ts_modes = { "n", "x", "o" }
keymap.set(ts_modes, "]m", ts_move("goto_next_start", "@function.outer"), { desc = "Siguiente función" })
keymap.set(ts_modes, "[m", ts_move("goto_previous_start", "@function.outer"), { desc = "Función anterior" })
keymap.set(ts_modes, "]M", ts_move("goto_next_end", "@function.outer"), { desc = "Fin de función siguiente" })
keymap.set(ts_modes, "[M", ts_move("goto_previous_end", "@function.outer"), { desc = "Fin de función anterior" })
keymap.set(ts_modes, "]c", ts_move("goto_next_start", "@class.outer"), { desc = "Siguiente clase" })
keymap.set(ts_modes, "[c", ts_move("goto_previous_start", "@class.outer"), { desc = "Clase anterior" })
keymap.set(ts_modes, "]C", ts_move("goto_next_end", "@class.outer"), { desc = "Fin de clase siguiente" })
keymap.set(ts_modes, "[C", ts_move("goto_previous_end", "@class.outer"), { desc = "Fin de clase anterior" })

-- Diagnósticos
keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Error anterior" })
keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Error siguiente" })
keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Ver detalle del error" })
keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Lista de todos los errores" })

-- Navegación entre pestañas
keymap.set("n", "<A-n>", "<Cmd>tabnext<CR>", { desc = "Tab siguiente", silent = true })
keymap.set("n", "<A-p>", "<Cmd>tabprevious<CR>", { desc = "Tab anterior", silent = true })

-- Navegación entre buffers
keymap.set("n", "<C-n>", "<Cmd>bnext<CR>", { desc = "Buffer siguiente", silent = true })
keymap.set("n", "<C-p>", "<Cmd>bprevious<CR>", { desc = "Buffer anterior", silent = true })
keymap.set("n", "<leader>bn", "<Cmd>bnext<CR>", { desc = "Buffer siguiente", silent = true })
keymap.set("n", "<leader>bp", "<Cmd>bprevious<CR>", { desc = "Buffer anterior", silent = true })
keymap.set("n", "<leader>wd", "<Cmd>bdelete<CR>", { desc = "Cerrar buffer", silent = true })
keymap.set("n", "<Leader><PageUp>", "<Cmd>bprevious<CR>", { desc = "Buffer anterior", silent = true })
keymap.set("n", "<Leader><PageDown>", "<Cmd>bnext<CR>", { desc = "Buffer siguiente", silent = true })

-- Todo Comments
keymap.set("n", "<leader>tt", function()
  require("lazy").load({ plugins = { "telescope.nvim", "todo-comments.nvim" } })
  vim.cmd("TodoTelescope")
end, { desc = "Buscar todos" })
keymap.set("n", "]t", function() require("todo-comments.jump").next() end, { desc = "Todo siguiente" })
keymap.set("n", "[t", function() require("todo-comments.jump").prev() end, { desc = "Todo anterior" })

-- Folding (Ufo)
keymap.set("n", "zR", function() require("ufo").openAllFolds() end, { desc = "Abrir todos los folds" })
keymap.set("n", "zM", function() require("ufo").closeAllFolds() end, { desc = "Cerrar todos los folds" })
keymap.set("n", "zr", function() require("ufo").openFoldsExceptKinds() end, { desc = "Abrir folds excepto funciones" })
keymap.set("n", "zm", function() require("ufo").closeFoldsWith() end, { desc = "Cerrar folds con" })
keymap.set("n", "zk", function() require("ufo").goPreviousClosedFold() end, { desc = "Fold anterior" })
keymap.set("n", "zj", function() require("ufo").goNextClosedFold() end, { desc = "Fold siguiente" })

-- Leap (navegación rápida)
keymap.set({ "n", "x", "o" }, "<Leader>s", "<Plug>(leap-forward)", { desc = "Leap forward" })
keymap.set({ "n", "x", "o" }, "<Leader>S", "<Plug>(leap-backward)", { desc = "Leap backward" })

-- EasyAlign (alinear código)
keymap.set("n", "ga", "<Plug>(EasyAlign)")
keymap.set("x", "ga", "<Plug>(EasyAlign)")

-- Comentarios
keymap.set("n", "<leader>cc", function() require("Comment.api").toggle.linewise.current() end, { desc = "Comentar línea" })
keymap.set("n", "<leader>cb", function() require("Comment.api").toggle.blockwise.current() end, { desc = "Comentar bloque" })
