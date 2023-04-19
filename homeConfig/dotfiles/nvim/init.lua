-- Line Numbering
  vim.o.relativenumber = true
  vim.o.number = true
  vim.cmd('highlight LineNr ctermfg=DarkGray')

-- Enable clipboard
  vim.o.clipboard = "unnamedplus"


-- Load packer.nvim
  local packer_install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if  vim.fn.empty(vim.fn.glob(packer_install_path)) > 0 then
        vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. packer_install_path)
        vim.cmd 'packadd packer.nvim'
  end
  dofile(vim.fn.stdpath('config') .. '/plugins.lua')

-- LSP and LSPInstall setup
  local nvim_lsp = require('lspconfig')
  local lspinstall = require('lspinstall')

  lspinstall.setup()

  for _, lsp in ipairs(lspinstall.installed_servers()) do
      nvim_lsp[lsp].setup {
          on_attach = function(client, bufnr)
              client.resolved_capabilities.document_formatting = false
              require('lsp_signature').on_attach()
          end,
      }
  end

-- Keep Cursor
  vim.o.guicursor = ''

-- Indentation
  vim.opt.shiftwidth = 2
  vim.opt.softtabstop = 2
  vim.opt.expandtab = true
  vim.opt.tabstop = 2

-- Treesitter Enable
  require'nvim-treesitter.configs'.setup {
    highlight = {
      enable = true,
    },
  }

-- Init Snippets
  vim.g.snipMate = { snippet_version = 1 }
