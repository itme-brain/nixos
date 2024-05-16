{ pkgs, lib, config, ... }:

{
  programs.firefox.enable = true;

  home.packages = with pkgs; [
    tor-browser
    brave
  ];
}
