{ lib, config, ... }:

with lib;
let
  gui = config.modules.user.gui.wm;
  wm = {
    enable = builtins.any (mod: mod.enable or false) (builtins.attrValues gui);
  };

in
{
  cd = "cd -L";
  grep = "grep --color";
  tree = "eza --tree --icons=never";
  lt = mkForce "eza --tree --icons=never";
  open = mkIf wm.enable "xdg-open";
}
