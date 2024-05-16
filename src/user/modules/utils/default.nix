{ pkgs, lib, config, ... }:

{
  home.packages = with pkgs; [
    wget curl neofetch
    unzip fping calc fd pciutils
    rsync zip lshw
  ];
}
