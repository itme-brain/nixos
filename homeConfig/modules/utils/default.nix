{ pkgs, lib, config, ... }:

with lib;
let 
  cfg = config.modules.utils;

in 
{ options.modules.utils = { enable = mkEnableOption "utils"; };
  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      wget curl tree neofetch
      unzip fping calc qrencode
      fd pkg-config pciutils
      mdbook rsync docker gcc gnumake
      exercism pandoc texlive.combined.scheme-tetex
      pdftk zoom-us zip teams-for-linux
      aerc weechat
    ];

    home.file.".config/aerc" = {
      source = ./aerc;
      recursive = true;
    };
  };
}
