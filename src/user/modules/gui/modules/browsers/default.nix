{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.browsers;
in
{ options.modules.user.gui.browsers = { enable = mkEnableOption "Enable browsers"; };
  config = mkIf cfg.enable {
    programs.firefox.enable = true;

    home.packages = with pkgs; [
     tor-browser
     brave
    ];
  };
}
