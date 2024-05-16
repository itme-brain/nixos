{ lib, config, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = import ./config/alacritty.nix;
  };
}
