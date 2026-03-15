{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.utils.irc;

in
{ options.modules.user.utils.irc = { enable = mkEnableOption "user.utils.irc"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      weechat
    ];
    programs.bash.shellAliases = {
      chat = "weechat";
    };
  };
}
