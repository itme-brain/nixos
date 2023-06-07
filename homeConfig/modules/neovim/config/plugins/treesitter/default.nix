{ pkgs, ...}:

with pkgs.vimPlugins;

[
  { plugin = nvim-treesitter.withAllGrammars;
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
