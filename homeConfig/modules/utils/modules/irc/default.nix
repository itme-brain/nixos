{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.irc;

in
{ options.modules.irc = { enable = mkEnableOption "irc"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      weechat
    ];
  };
}
