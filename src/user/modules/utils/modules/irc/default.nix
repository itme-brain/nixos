{ pkgs, lib, config, ... }:

{
  home.packages = with pkgs; [
    weechat
  ];
  programs.bash.shellAliases = {
    chat = "weechat";
  };
}
