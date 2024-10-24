{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.dev.pcb;

in
{ options.modules.user.dev.pcb = { enable = mkEnableOption "Enable PCB development suite"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      arduino-ide
      kicad-small
      ngspice
    ];
  };
}
