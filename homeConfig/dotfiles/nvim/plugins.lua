-- Load packer.nvim
local packer = require('packer')

-- Start defining plugins
return packer.startup(function(use)
  -- Install packer.nvim
  use 'wbthomason/packer.nvim'

  -- Github Theme
  use ({ 'projekt0n/github-nvim-theme', tag = 'v0.0.7',
    config = function()
      require('github-theme').setup({
        theme_style = "dark_default",
      })
    end
  })

  -- Indent-blankline
  use {"lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup {
      }
    end,
  }

  -- Neo-Tree
  use {"nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    requires = { 
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", 
	    "MunifTanjim/nui.nvim",
    }
  }
 
  -- Vim Snippets
  use {
    'garbas/vim-snipmate',
    requires = {
      'MarcWeber/vim-addon-mw-utils',
      'tomtom/tlib_vim',
    }
  }
  use 'honza/vim-snippets'

  -- Lualine
  use {'nvim-lualine/lualine.nvim',
  after = 'github-nvim-theme',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
      config = function()
        require('lualine').setup {
          options = {
            theme = 'auto'
          }
        }  
      end
  }

  -- Git Blame Line
  use {
  'tveskag/nvim-blame-line',
    requires = {'nvim-lua/plenary.nvim'},
  }

  -- Git Integration
  use { 'TimUntersberger/neogit', 
    requires = 'nvim-lua/plenary.nvim'
  }

  -- Autobracket
  use {'windwp/nvim-autopairs', 
    config = function() 
      require('nvim-autopairs').setup() 
    end
  }

  
  -- Color Preview
  use { 'ap/vim-css-color', 
    ft = { 
      'css', 
      'sass', 
      'scss', 
      'rasi', 
      'markdown' 
    } 
  }

  -- LSP Config
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-compe'
  use 'kabouzeid/nvim-lspinstall'

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

  require('compe').setup({
      enabled = true,
      source = {
          path = true,
          buffer = true,
          nvim_lsp = true,
          nvim_lua = true,
          treesitter = true,
      },
  })
end)
