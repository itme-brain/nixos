{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.dev.pcb;

in
{ options.modules.user.gui.dev.pcb = { enable = mkEnableOption "Enable PCB development suite"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      arduino-ide
      kicad-small
      ngspice
    ];
  };
}
