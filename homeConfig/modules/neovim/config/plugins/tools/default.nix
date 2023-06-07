 { pkgs, ... }:

with pkgs.vimPlugins;
[
  { plugin = lazygit-nvim; }
  { plugin = nvim-web-devicons; }
  { plugin = lualine-nvim; }
  { plugin = neo-tree-nvim; }
]
