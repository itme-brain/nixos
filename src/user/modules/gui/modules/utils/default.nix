{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.utils;
  gui = config.modules.user.gui.wm;

  wm = {
    enable = builtins.any (mod: mod.enable or false) (builtins.attrValues gui);
  };

in
{ options.modules.user.gui.utils = { enable = mkEnableOption "user.gui.utils"; };
  config = mkIf (cfg.enable && wm.enable) {
    programs.btop.enable = true;
    home.packages = with pkgs; [
      gimp
      libreoffice

      teams-for-linux
    ];
  };
}
