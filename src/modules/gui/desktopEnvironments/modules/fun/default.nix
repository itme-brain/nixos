{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.gui.fun;

in
{ options.modules.gui.fun = { enable = mkEnableOption "gui.fun"; };
  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
        input-overlay
      ];
    };

    home.packages = with pkgs; [
      spotify
      webcord
      showmethekey
    ];
  };
}
