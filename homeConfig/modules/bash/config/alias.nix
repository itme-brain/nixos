{ flakePath, ... }:

{
  nixup = "sudo nixos-rebuild switch --flake ${flakePath}/.#desktop";
  chat = "weechat";
  open = "xdg-open";
}
