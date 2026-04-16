local opt = vim.opt

vim.g.mapleader = " "

-- Configurar easymotion antes de que carguen los plugins
vim.g.easymotion_leader_key = '<Leader>'

-- Tus ajustes de Vim adaptados
opt.number = true
opt.relativenumber = true
opt.encoding = "utf-8"
opt.tabstop = 4
opt.shiftwidth = 4
opt.autoindent = true
opt.expandtab = true
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.updatetime = 300
opt.clipboard = "unnamedplus"
opt.signcolumn = "yes"
opt.termguicolors = true
opt.cursorline = true

-- Variable para Rust (equivalente a tu let g:rustfmt_autosave = 1)
vim.g.rustfmt_autosave = 1

-- Registrar el tipo de archivo blade
vim.filetype.add({
  pattern = {
    ['.*%.blade%.php'] = 'blade',
  },
})

-- Restaurar posición del cursor (Tu autocmd de Vim)
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Fold inicial al abrir archivos (fold manual después)
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        vim.cmd("normal! zM")
    end,
})
