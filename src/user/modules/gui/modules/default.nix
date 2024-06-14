{ config, lib, ... }:

let
  wm = {
    enable = builtins.any (mod: mod.enable or false) (builtins.attrValues config.modules.user.gui.wm);
  };

in
{
  imports = if wm.enable then [
    ./alacritty
    ./browsers
    ./corn
    ./fun
    ./utils
    ./writing
  ] else [];
}
