local php_ns = require("core.php-namespace")

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.php",
  callback = function()
    php_ns.auto_namespace()
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local dir = vim.fn.expand("%:p:h")
    if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})
