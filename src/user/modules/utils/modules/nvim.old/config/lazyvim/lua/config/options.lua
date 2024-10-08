-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.cmd([[
  autocmd FileType c,cpp,haskell,python setlocal tabstop=4 shiftwidth=4 softtabstop=4
]])

vim.cmd([[
  au BufRead,BufNewFile *.purs set filetype=purescript
]])

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.o.termguicolors = true
vim.opt.guicursor = "n-v-c:block,i:block,r:block"
vim.g.autoformat = false

vim.cmd([[highlight PmenuSel guifg=#53565d guibg=#f0c981]])
