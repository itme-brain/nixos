{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.browsers;
  gui = config.modules.user.gui.wm;

  wm = {
    enable = builtins.any (mod: mod.enable or false) (builtins.attrValues gui);
  };

in
{ options.modules.user.gui.browsers = { enable = mkEnableOption "user.gui.browsers"; };
  config = mkIf (cfg.enable && wm.enable) {
    programs.firefox.enable = true;

    home.packages = with pkgs; [
     tor-browser
     brave
    ];
  };
}
