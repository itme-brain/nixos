{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.fun;
  gui = config.modules.user.gui.wm;

  wm = {
    enable = builtins.any (mod: mod.enable or false) (builtins.attrValues gui);
  };

in
{ options.modules.user.gui.fun = { enable = mkEnableOption "user.gui.fun"; };
  config = mkIf (cfg.enable && wm.enable) {
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
