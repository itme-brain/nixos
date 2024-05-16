{ pkgs, lib, config, ... }:

{
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
}
