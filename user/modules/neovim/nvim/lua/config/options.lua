vim.o.clipboard = "unnamedplus"
vim.g.autoformat = false

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
-- Enable true color if terminal supports it (disabled in TTY/headless)
if vim.env.COLORTERM == "truecolor" or vim.env.COLORTERM == "24bit" then
  vim.opt.termguicolors = true
end

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.guicursor = "n-v-c:block,i:block,r:block"

vim.opt.fillchars = { eob = " " }

local options_group = vim.api.nvim_create_augroup("config_options", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = options_group,
  pattern = { "python", "haskell", "c", "cpp" },
  callback = function()
    local opt = vim.opt_local
    opt.tabstop = 4
    opt.shiftwidth = 4
    opt.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = options_group,
  pattern = "*.purs",
  callback = function(event)
    vim.bo[event.buf].filetype = "purescript"
  end,
})
