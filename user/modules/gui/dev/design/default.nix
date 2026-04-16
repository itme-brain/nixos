{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.dev.design;

in
{ options.modules.user.gui.dev.design = { enable = mkEnableOption "Enable design tools"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      penpot-desktop
    ];
  };
}
