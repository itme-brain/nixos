{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.gui.browsers;

in
{ options.modules.gui.browsers = { enable = mkEnableOption "gui.browsers"; };
  config = mkIf cfg.enable {
    programs.firefox.enable = true;

    home.packages = with pkgs; [
     tor-browser
    ];
  };
}
