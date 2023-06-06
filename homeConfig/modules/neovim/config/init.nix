''
lua << EOF
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.expandtab = true 

  vim.o.guicursor = \'\'
  vim.o.clipboard = "unnamedplus"

  vim.o.foldmethod = "indent"
  vim.o.foldlevelstart = 99

  vim.cmd([[
    au BufRead,BufNewFile *.purs set filetype=purescript
  ]])
EOF
''
