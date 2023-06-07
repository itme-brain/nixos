''

vim.o.relativenumber = true
vim.o.number = true
vim.cmd('highlight LineNr ctermfg=DarkGray')

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true 

vim.o.clipboard = "unnamedplus"

vim.o.foldmethod = "indent"
vim.o.foldlevelstart = 99

vim.cmd([[
  au BufRead,BufNewFile *.purs set filetype=purescript
]])


vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  -- Disable virtual_text
  virtual_text = false,
})

vim.api.nvim_set_keymap('n', '<PageUp>', '<PageUp>zz', {noremap = true})
vim.api.nvim_set_keymap('n', '<PageDown>', '<PageDown>zz', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-U>', '<C-U>zz', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-D>', '<C-D>zz', {noremap = true})

''
