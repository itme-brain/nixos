{ pkgs, ... }:

with pkgs.vimPlugins;
[
  { plugin = LazyVim; }
]
