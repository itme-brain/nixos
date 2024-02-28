{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.utils.irc;

in
{ options.modules.utils.irc = { enable = mkEnableOption "utils.irc"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      weechat
    ];
    programs.bash.shellAliases = {
      chat = "weechat";
    };
  };
}
