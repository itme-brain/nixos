{ pkgs, ... }:

#let
#  github-theme = pkgs.vimUtils.buildVimPlugin {
#    name = "github-theme";
#    src = builtins.fetchTarball {
#      url = "https://github.com/projekt0n/github-nvim-theme/archive/refs/tags/v1.0.0.tar.gz";
#      sha256 = "15c65qw1sgw3v5wrwbg5f1fqb82qq1yr44g2nrwb7b7m134jyr1h";
#    };
#  };
#
#in
with pkgs.vimPlugins; 
[
#  {
#    plugin = github-theme;
#    config = '' 
#    lua << EOF
#      vim.cmd('colorscheme github_dark_high_contrast')
#    EOF
#    '';
#  }

  { plugin = lazygit-nvim; }

  {
    plugin = LazyVim;
    config = '' 
    lua << EOF
      return {
        {'williamboman/mason.nvim', enabled = false },
        {'williamboman/mason-lspconfig.nvim', enabled = false },
        {'nvim-treesitter/nvim-treesitter', enabled = false },
      } 
    EOF
    '';
  }
  
  {
    plugin = lsp-zero-nvim;
    config = '' 
    lua << EOF
      branch = 'v2.x'
      requires = {
        {'neovim/nvim-lspconfig'},
        {'hrsh7th/nvim-cmp'},
        {'hrsh7th/cmp-nvim-lsp'},
        {'L3MON4D3/LuaSnip'},
      }
    EOF
    '';
  }

  {
    plugin = nvim-treesitter.withAllGrammars;
    config = '' 
      lua << EOF
        require'nvim-treesitter.configs'.setup {
          highlight = {
            enable = true,
          },
        }
      EOF
    '';
  }
]      
