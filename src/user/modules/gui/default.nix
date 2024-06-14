{ config, ... }:

let
  gui = config.modules.user.gui.wm;

  wm = {
    enable = builtins.any (mod: mod.enable or false) (builtins.attrValues gui);
  };

in
{
  imports = [
    ./wm
  ] ++ (if wm.enable then [
    ./modules
  ] else []);
}
