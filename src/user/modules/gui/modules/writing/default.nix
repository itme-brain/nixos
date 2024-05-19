{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.writing;
  gui = config.modules.user.gui.wm;

  wm = {
    enable = builtins.any (mod: mod.enable or false) (builtins.attrValues gui);
  };

in
{ options.modules.user.gui.writing = { enable = mkEnableOption "user.gui.writing"; };
  config = mkIf (cfg.enable && wm.enable) {
    home.packages = with pkgs; [
      mdbook
      texlive.combined.scheme-tetex
      pandoc
      asciidoctor
    ];
  };
}
