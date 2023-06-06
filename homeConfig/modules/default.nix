{ pkgs, lib, config, ... }:

{ 
  imports = [ 
    ./alacritty/default.nix
    ./bash/default.nix
    ./browsers/default.nix
    ./corn/default.nix
    ./fun/default.nix
    ./git/default.nix
    ./gpg/default.nix
    ./gui/default.nix
    ./neovim/default.nix
    ./security/default.nix
    ./utils/default.nix
  ]; 
}
