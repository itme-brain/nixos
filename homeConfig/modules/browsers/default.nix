{ pkgs, lib, config, ... }:

with lib;
let 
  cfg = config.modules.browsers;

in 
{ options.modules.browsers = { enable = mkEnableOption "browsers"; };
  config = mkIf cfg.enable {
    programs.firefox.enable = true;
    programs.chromium.enable = true;

    home.packages = with pkgs; [
      google-chrome
      (tor-browser-bundle-bin.override {
        useHardenedMalloc = false; # NixOS bug requires this
      })
    ];
  };
}
