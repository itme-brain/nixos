-- Define vim
  vim = vim or {}

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

-- Init Snippets
  vim.g.snipMate = { snippet_version = 1 }

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
  local nvim_lsp = require('lspconfig')

  local function on_attach(client, bufnr)
    client.server_capabilities.document_formatting = false
    require('lsp_signature').on_attach()
  end

-- Add / Remove LSP's HERE
  local servers = {
    tsserver = { cmd = { "tsserver", "--stdio" } },
    pyright = { cmd = { "pyright-langserver", "--stdio" } },
    lua_ls = { cmd = { "lua-language-server" } },
    rnix = { cmd = { "rnix-lsp" } },

    vscode_html = { cmd = { "vscode-html-language-server", "--stdio" } },
    vscode_css = { cmd = { "vscode-css-language-server", "--stdio" } },
    vscode_markdown = { cmd = { "vscode-markdown-language-server", "--stdio" } },
    vscode_json = { cmd = { "vscode-json-language-server", "--stdio" } },
    vscode_eslint = { cmd = { "vscode-eslint-language-server", "--stdio" } },
  }

  for lsp, config in pairs(servers) do
    nvim_lsp[lsp].setup {
      cmd = config.cmd,
      on_attach = on_attach,
    }
  end

  vim.cmd('highlight! link LspDiagnosticsVirtualTextError LspDiagnosticsVirtualTextErrorTransparent')
  vim.cmd('highlight! LspDiagnosticsVirtualTextErrorTransparent guibg=none gui=none blend=50')
