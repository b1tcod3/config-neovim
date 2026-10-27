local php_ns = require("core.php-namespace")

local aug = vim.api.nvim_create_augroup("UserAutocmds", { clear = true })

local function format_buffer(buf)
  if vim.bo[buf].buftype ~= "" or vim.b[buf].disable_autoformat then
    return
  end

  local clients = vim.lsp.get_clients({ bufnr = buf, method = "textDocument/formatting" })
  if #clients == 0 then
    return
  end

  vim.lsp.buf.format({
    bufnr = buf,
    async = false,
    timeout_ms = 2000,
    filter = function(client)
      return client:supports_method("textDocument/formatting")
    end,
  })
end

-- Al guardar: crear directorios padres, insertar namespace PHP y formatear.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = aug,
  callback = function(args)
    local buf = args.buf

    local name = vim.api.nvim_buf_get_name(buf)
    if name ~= "" then
      local dir = vim.fn.fnamemodify(name, ":h")
      if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
      end
    end

    if vim.bo[buf].filetype == "php" then
      php_ns.auto_namespace(buf)
    end

    format_buffer(buf)
  end,
})

-- Restaurar posición del cursor al abrir archivos.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = aug,
  callback = function(args)
    if args.buf ~= vim.api.nvim_get_current_buf() or vim.bo[args.buf].buftype ~= "" then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Resaltar brevemente el texto copiado.
if vim.hl and vim.hl.on_yank then
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = aug,
    callback = function()
      vim.hl.on_yank({ timeout = 150 })
    end,
  })
end

-- Invalidar la caché de PSR-4 cuando cambia composer.json.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = aug,
  pattern = { "composer.json", "*/composer.json" },
  callback = function()
    php_ns.clear_cache()
  end,
})
