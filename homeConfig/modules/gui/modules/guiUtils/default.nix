{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.guiUtils;

in
{ options.modules.guiUtils = { enable = mkEnableOption "guiUtils"; };
  config = mkIf cfg.enable {
    programs.btop.enable = true;
    home.packages = with pkgs; [
      gimp
      pdftk
      teams-for-linux
      zoom-us
      exercism
    ];
  };
}
