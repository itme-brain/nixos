{ pkgs, lib, config, ... }:

{
  programs.btop.enable = true;
  home.packages = with pkgs; [
    gimp
    libreoffice

    teams-for-linux
  ];
}
