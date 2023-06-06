{ pkgs, lib, config, me, ... }:

with lib;
let 
  cfg = config.modules.browsers;

in 
{ options.modules.browsers = { enable = mkEnableOption "browsers"; };
  config = mkIf cfg.enable {
    programs.firefox = {
      enabled = true;
      profiles.${me} = import (config/${me}.nix) { inherit pkgs; };
    };

    home.packages = [
      google-chrome
      (tor-browser-bundle-bin.override {
        useHardenedMalloc = false; # NixOS bug requires this
      })
    ];
  };
}
