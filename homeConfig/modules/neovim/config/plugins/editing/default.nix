{ pkgs, ... }:

with pkgs.vimPlugins;
[
  { plugin = indent-blankline-nvim; }
  { plugin = auto-pairs; } 
  { plugin = vim-css-color; }
]
