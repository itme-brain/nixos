{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.neovim;

    github-theme = pkgs.vimUtils.buildVimPlugin {
      name = "github-theme";
      src = pkgs.fetchFromGithub {
        owner = "projekt0n";
        repo = "github-nvim-theme";
        rev = "62b7b54a90c70c20cd1641f9facfced46bdd3561";
        sha256 = "0cwr3b5r2ac7aizxmwb3mlhdc2sh0pw670vcwps79x9jp52yrj2y";
      };
    };
in {
    options.modules.neovim = { enable = mkEnableOption "neovim"; };
    config = mkIf cfg.enable {
  
      home.file.".config/nvim" = {
        source = ./nvim;
        recursive = true;
      };
      
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;

        plugins = with pkgs.vimPlugins; [
          
          {
            plugin = github-theme;
            config = '' 
            lua << EOF
              vim.cmd('colorscheme github_dark_high_contrast')
            EOF
            '';
          }

          lazygit.nvim
          {
            plugin = LazyVim;
            config = '' 
            lua << EOF
              return {
                {'williamboman/mason.nvim', enabled = false },
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
            '';
          }

          {
            plugin = nvim-treesitter.withAllGrammars
            config = '' 
              lua << EOF
                
              EOF
            '';
          }
        ];
      };

      home.packages = with pkgs; [
        nil nixfmt
        sumneko-lua-language-server stylua
        haskell-language-server hlint
      ];
  };
}
