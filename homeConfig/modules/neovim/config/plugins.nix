{ pkgs, ... }:

let
  github-theme = pkgs.vimUtils.buildVimPlugin {
    name = "github-theme";
    src = pkgs.fetchFromGithub {
      owner = "projekt0n";
      repo = "github-nvim-theme";
      rev = "ea713c37691b2519f56cd801a2330bdf66393d0f";
      sha256 = "0cwr3b5r2ac7aizxmwb3mlhdc2sh0pw670vcwps79x9jp52yrj2y";
    };
  };

in
with pkgs.vimPlugins; 
[
  {
    plugin = github-theme;
    config = '' 
    lua << EOF
      vim.cmd('colorscheme github_dark_high_contrast')
    EOF
    '';
  }

  { plugin = lazygit.nvim; }

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
