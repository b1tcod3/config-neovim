local opt = vim.opt

-- Opciones de interfaz y comportamiento
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

-- Registrar el tipo de archivo blade
vim.filetype.add({
  pattern = {
    ['.*%.blade%.php'] = 'blade',
  },
})


