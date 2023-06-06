{ pkgs, lib, config, ... }:

with lib;
let 
  cfg = config.modules.browsers;

in 
{ options.modules.browsers = { enable = mkEnableOption "browsers"; };
  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles.bryan = import config/bryan.nix { inherit pkgs; };
    };

    home.packages = [
      google-chrome
      (tor-browser-bundle-bin.override {
        useHardenedMalloc = false; # NixOS bug requires this
      })
    ];
  };
}
