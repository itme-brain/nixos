{ pkgs, ... }:

with pkgs.vimPlugins;
[
  { plugin = catppuccin-nvim; }
]
