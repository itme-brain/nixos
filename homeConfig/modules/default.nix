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
    ./vim
    ./utils
  ];
}
