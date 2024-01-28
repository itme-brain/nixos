{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.utils;

in
{ options.modules.utils = { enable = mkEnableOption "utils"; };
  imports = [ ./modules ];
  config = mkIf cfg.enable {
    modules = {
      vim.enable = false;
      email.enable = true;
      irc.enable = true;
      dev.enable = true;
    };

    home.packages = with pkgs; [
      wget curl tree neofetch
      unzip fping calc qrencode
      fd pkg-config pciutils
      mdbook rsync pandoc texlive.combined.scheme-tetex
      zip asciidoctor
    ];
  };
}
