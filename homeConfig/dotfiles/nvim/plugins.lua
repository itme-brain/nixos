-- Load packer.nvim
local packer = require('packer')

-- Start defining plugins
return packer.startup(function(use)
  -- Install packer.nvim
  use 'wbthomason/packer.nvim'


  -- Install indent-blankline.nvimuse
  use {"lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup {
      }
    end,
  }

  -- Neo-Tree
  use {
    "nvim-neo-tree/neo-tree.nvim",
      branch = "v2.x",
      requires = { 
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", 
	      "MunifTanjim/nui.nvim",
      }
  }
  
  -- Lualine (bottom line)
  use {
  'nvim-lualine/lualine.nvim',
  requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    config = function()
      require('lualine').setup {}  
    end
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


end)

