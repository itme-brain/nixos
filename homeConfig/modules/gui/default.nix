{ lib, config, ... }:

with lib;
let
  cfg = config.modules.gui;

in
{ options.modules.gui = { enable = mkEnableOption "gui"; };
  imports = [ ./desktopEnvironments ];
  config = mkIf cfg.enable {
    modules = {
      sway.enable = true;
    };
  };
}
