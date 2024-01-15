{ pkgs, lib, config, ... }:

with lib;
let
  hostname = config.systemName;
  cfg = config.modules.utils;
  socratesPkgs = with pkgs; [
      wget curl tree neofetch
      unzip fping calc qrencode
      fd pkg-config pciutils
      mdbook rsync docker gcc gnumake
      exercism pandoc texlive.combined.scheme-tetex
      pdftk zoom-us zip teams-for-linux
      aerc weechat
  ];
  archimedesPkgs = with pkgs; [
    wget curl tree qrencode fd
    zip gcc gnumake docker rsync
  ];
  selectedPkgs =
    if hostname == "archimedes"
      then archimedesPkgs
    else socratesPkgs;
in
{ options.modules.utils = { enable = mkEnableOption "utils"; };
  config = mkIf cfg.enable {
    home.packages = selectedPkgs;

    home.file.".config/aerc" = {
      source = ./aerc;
      recursive = true;
    };
  };
}
