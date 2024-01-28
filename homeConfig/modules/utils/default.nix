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
      mdbook rsync docker exercism pandoc
      texlive.combined.scheme-tetex glibc
      pdftk zoom-us zip teams-for-linux
      aerc weechat asciidoctor
      gcc
    ];

    home.file.".config/aerc" = {
      source = ./aerc;
      recursive = true;
    };
  };
}
