local opt = vim.opt

-- Interfaz
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes:2"
opt.termguicolors = true
opt.pumheight = 12
opt.mouse = "a"
opt.confirm = true
opt.breakindent = true

-- Edición
opt.encoding = "utf-8"
opt.tabstop = 4
opt.shiftwidth = 4
opt.autoindent = true
opt.expandtab = true
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.updatetime = 300
opt.clipboard = "unnamedplus"

-- Búsqueda y navegación
opt.ignorecase = true
opt.smartcase = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"

-- Folds: abiertos al abrir archivos. ufo se encarga del provider y los atajos.
opt.foldenable = true
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99

