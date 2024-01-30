{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.gui.utils;

in
{ options.modules.gui.utils = { enable = mkEnableOption "gui.utils"; };
  config = mkIf cfg.enable {
    programs.btop.enable = true;
    home.packages = with pkgs; [
      gimp
      okular
      pdftk

      teams-for-linux
      zoom-us
      exercism
    ];
  };
}
