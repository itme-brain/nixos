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
     tor-browser vieb
    ];
    home.file.".config/Vieb/viebrc".source = ./config/viebrc;
  };
}
