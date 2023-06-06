{ pkgs, lib, config, ... }:

with lib;
let 
  cfg = config.modules.PROGRAM;

in 
{ options.modules.PROGRAM = { enable = mkEnableOption "PROGRAM"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      spotify
      discord
      steam
    ];
  };
}
