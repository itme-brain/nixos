{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.fun;

in
{ options.modules.user.gui.fun = { enable = mkEnableOption "user.gui.fun"; };
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
    ];
  };
}
