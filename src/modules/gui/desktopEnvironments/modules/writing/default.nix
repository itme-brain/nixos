{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.gui.writing;

in
{ options.modules.gui.writing = { enable = mkEnableOption "gui.writing"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mdbook
      texlive.combined.scheme-tetex
      pandoc
      asciidoctor
    ];
  };
}
