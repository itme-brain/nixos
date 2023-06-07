{ pkgs, lib, config, ... }:

{ 
  imports = [ 
    ./alacritty
    ./bash
    ./browsers
    ./corn
    ./fun
    ./git
    ./gpg
    ./gui
    ./neovim
    ./security
    ./utils
  ]; 
}
