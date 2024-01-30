{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.utils;

in
{ options.modules.utils = { enable = mkEnableOption "utils"; };
  imports = [ ./modules ];
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wget curl tree neofetch
      unzip fping calc qrencode
      fd pkg-config pciutils
      rsync zip
    ];
  };
}
