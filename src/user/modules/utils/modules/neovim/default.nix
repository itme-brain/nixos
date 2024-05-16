{ pkgs, lib, config, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = import ./config/pkgs.nix;
  };

  home.file.".config/nvim" = {
    source = ./config/lazyvim;
    recursive = true;
  };
}
