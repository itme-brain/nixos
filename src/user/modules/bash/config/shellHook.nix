{ lib, config, ... }:

with lib;
let
  tmux = config.modules.user.tmux;
  gui = config.modules.user.gui.wm;
  sway = config.modules.user.gui.wm.sway;
  hyprland = config.modules.user.gui.wm.hyprland;

  wm = {
    enable = builtins.any (mod: mod.enable or false) (builtins.attrValues gui);
  };

in
''
case $- in
  *i*)
    ${optionalString wm.enable ''
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      ${optionalString sway.enable ''
      exec sway
      ''
      }
      ${optionalString hyprland.enable ''
      exec Hyprland
      ''
      }
      exit 0
    fi
    ''}
    ${optionalString tmux.enable ''
    if [ -z "$DISPLAY" ] && [ -z "$TMUX" ]; then
      exec tmux
    fi
    ''}
    ;;
esac
''
