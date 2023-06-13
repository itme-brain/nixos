{ pkgs, lib, config, ... }:

with lib;
let 
  cfg = config.modules.fun;

in 
{ options.modules.fun = { enable = mkEnableOption "fun"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      spotify
      discord
      steam

      obs-studio
      obs-studio-plugins.wlrobs
      obs-studio-plugins.obs-pipewire-audio-capture
    ];
  };
}
