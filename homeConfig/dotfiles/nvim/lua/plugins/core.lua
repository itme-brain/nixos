return {
  {
    'projekt0n/github-nvim-theme',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('github-theme').setup({
        options = {
          transparent = true;
        }
      })

      vim.cmd('colorscheme github_dark_high_contrast')
    end,
  },

  {'williamboman/mason.nvim', enabled = false },
  
{
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v2.x',
  dependencies = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},             -- Required
    {'williamboman/mason-lspconfig.nvim'}, -- Optional

    -- Autocompletion
    {'hrsh7th/nvim-cmp'},     -- Required
    {'hrsh7th/cmp-nvim-lsp'}, -- Required
    {'L3MON4D3/LuaSnip'},     -- Required
  }
}

--  {
--    "neovim/nvim-lspconfig",
--    ---@class PluginLspOpts
--    opts = {
--      ---@type lspconfig.options
--      servers = {
--        html = {},
--        cssls = {},
--        jsonls = {},
--        marksman = {},
--        tsserver = {},
--        tailwindcss = {},
--        volar = {},
--
--        lua_ls = {},
--        
--        nil_ls = {},
--        pyright = {},
--        
--      --hls = {},
--        rust_analyzer = {},
--        diagnosticls = {},
--      },
--    },
--  },
}
