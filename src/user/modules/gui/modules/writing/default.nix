{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.writing;

in
{ options.modules.user.gui.writing = { enable = mkEnableOption "Enable writing tools"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mdbook
      texlive.combined.scheme-tetex
      pandoc
      asciidoctor
      evince
    ];
  };
}
