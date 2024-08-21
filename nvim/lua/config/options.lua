vim.o.clipboard = "unnamedplus"
vim.g.autoformat = false

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.termguicolors = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = false
vim.opt.incsearch = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.o.termguicolors = false
vim.opt.guicursor = "n-v-c:block,i:block,r:block"

--vim.opt.fillchars = { eob = " " }

vim.cmd([[
  autocmd FileType python,haskell,c,cpp setlocal tabstop=4 shiftwidth=4 softtabstop=4
]])

vim.cmd([[
  au BufRead,BufNewFile *.purs set filetype=purescript
]])
