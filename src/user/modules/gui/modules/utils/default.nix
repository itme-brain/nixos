{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.utils;

in
{ options.modules.user.gui.utils = { enable = mkEnableOption "user.gui.utils"; };
  config = mkIf cfg.enable {
    programs.btop.enable = true;
    home.packages = with pkgs; [
      gimp
      libreoffice

      teams-for-linux
    ];
  };
}
