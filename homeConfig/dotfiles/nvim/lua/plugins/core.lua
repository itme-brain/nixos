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

  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        html = {},
        cssls = {},
        jsonls = {},
        marksman = {},
        tsserver = {},
        tailwindcss = {},
        volar = {},

        lua_ls = {},
        
        nil_ls = {},
        pyright = {},
        
      --hls = {},
        rust_analyzer = {},
        diagnosticls = {},
      },
    },
  },
}
