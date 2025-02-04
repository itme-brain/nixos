{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.utils;

in
{ options.modules.user.utils = { enable = mkEnableOption "user.utils"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wget curl fastfetch
      unzip fping calc fd pciutils
      rsync zip lshw wireshark
      calcurse
    ];

    programs.bash.shellAliases = {
      calendar = "${pkgs.calcurse}/bin/calcurse";
    };
  };
}
