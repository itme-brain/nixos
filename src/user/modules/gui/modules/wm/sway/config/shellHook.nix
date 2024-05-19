{ lib, config, ... }:

with lib;
let
  tmux = config.modules.user.tmux;

in
''
case $- in
  *i*)
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec sway
    fi

    ${optionalString tmux.enable ''
    if [ -z "$DISPLAY" ] && [ -z "$TMUX" ]; then
      exec tmux
    fi
    ''}
    ;;
esac
''
