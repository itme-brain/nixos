{ pkgs, lib, config, ... }:

with lib;
let 
  cfg = config.modules.browsers;

in 
{ options.modules.browsers = { enable = mkEnableOption "browsers"; };
  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles.brain = import config/brain.nix { inherit pkgs; };
    };

    home.packages = with pkgs; [
      google-chrome
      (tor-browser-bundle-bin.override {
        useHardenedMalloc = false; # NixOS bug requires this
      })
    ];
  };
}
