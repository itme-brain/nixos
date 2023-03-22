-- Line Numbering
  vim.o.relativenumber = true
  vim.o.number = true
  vim.cmd('highlight LineNr ctermfg=DarkGray')

-- Enable clipboard
  vim.o.clipboard = "unnamedplus"


-- Load packer.nvim
local packer_install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if vim.fn.empty(vim.fn.glob(packer_install_path)) > 0 then
    vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. packer_install_path)
    vim.cmd 'packadd packer.nvim'
end
dofile(vim.fn.stdpath('config') .. '/plugins.lua')

-- Keep Cursor
  vim.o.guicursor = ''

-- Indentation
  vim.opt.shiftwidth = 2
  vim.opt.softtabstop = 2
  vim.opt.expandtab = true
  vim.opt.tabstop = 2

