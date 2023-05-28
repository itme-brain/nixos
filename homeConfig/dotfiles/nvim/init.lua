-- Line Numbering
vim.o.relativenumber = true
vim.o.number = true
vim.cmd('highlight LineNr ctermfg=DarkGray')

-- Enable clipboard
vim.o.clipboard = "unnamedplus"

-- Keep Cursor
vim.o.guicursor = ''

-- Indentation
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.tabstop = 2

-- Folding
vim.o.foldmethod = "indent"
vim.o.foldlevelstart = 99

-- Init Snippets
vim.g.snipMate = { snippet_version = 1 }

-- Remaps
vim.api.nvim_set_keymap('n', '<PageUp>', '<PageUp>zz', {noremap = true})
vim.api.nvim_set_keymap('n', '<PageDown>', '<PageDown>zz', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-U>', '<C-U>zz', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-D>', '<C-D>zz', {noremap = true})

-- Load packer.nvim
local packer_install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if  vim.fn.empty(vim.fn.glob(packer_install_path)) > 0 then
      vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. packer_install_path)
      vim.cmd 'packadd packer.nvim'
end
dofile(vim.fn.stdpath('config') .. '/plugins.lua')

-- Treesitter Enable
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
}

-- Load LSP's
local function on_attach(client, bufnr)
  client.server_capabilities.document_formatting = true
  require('lsp_signature').on_attach()
  local function set_completeopt()
    vim.api.nvim_buf_set_option(bufnr, 'completeopt', 'menuone,noselect')
  end
  set_completeopt()
end

require('lazy-lsp').setup {
  excluded_servers = {
    "sqls", "ccls", "zk", "tsserver", "nil_ls",
  },

  default_config = {
    on_attach = on_attach,
  },

  configs = {
    lua_ls = { 
      settings = { Lua = { diagnostics = { globals = { "vim" }}}},
    },
  },
}

  -- TODO: This is supposed to change the opacity for the LSP in-line error messages but it is not.
vim.cmd('highlight! link LspDiagnosticsVirtualTextError LspDiagnosticsVirtualTextErrorTransparent')
vim.cmd('highlight! LspDiagnosticsVirtualTextErrorTransparent guibg=none gui=none blend=50')
