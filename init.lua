-- ~/.config/nvim/init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("core.options")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.notify("No se pudo clonar lazy.nvim. Revisa tu conexión a git.", vim.log.levels.ERROR)
    return
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  install = {
    missing = true,
    colorscheme = { "tokyonight" },
  },
  checker = { enabled = false },
  change_detection = { notify = false },
  performance = {
    cache = { enabled = true },
    rtp = {
      reset = true,
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = { border = "rounded" },
})

require("core.keymaps")
require("core.autocmds")
