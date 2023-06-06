{ config, lib, ... }:

let
  modifier = config.wayland.windowManager.sway.config.modifier;

in
{ enable = true;
  xwayland = true;
  wrapperFeatures.gtk = true;

  extraOptions = [
    "--unsupported-gpu"
    "--my-next-gpu-wont-be-nvidia"
  ];

  extraSessionCommands = ''
    export _JAVA_AWT_WM_NONREPARENTING=1
  '';

  config = {
    modifier = "Mod1";
    menu = "\${pkgs.rofi-wayland}/bin/rofi -show drun -show-icons -drun-icon-theme Qogir -font 'Noto Sans 14'";
    terminal = "\${pkgs.alacritty}/bin/alacritty";
    startup = [{ command = "exec { exec alacritty -e sh -c 'neofetch; exec $SHELL'"; always = true; }];

    input = {
      keyboard = {
        xkb_numlock = "enabled";
        xkb_layout = "us";
      };
      pointer = {
        accel_profile = "flat";
        pointer_accel = "0.65";
      };
    };

    bars = [
      {
        position = "top";
        statusCommand = ''while :; do echo "$(free -h | awk '/^Mem/ {print $3}') '|' $(date +'%I:%M:%S %p') '|' $(date +'%m-%d-%Y')"; sleep 1; done'';
        fonts = { 
          names = [ "Noto Sans" "Noto Emoji" "Noto Color Emoji" ];
          size = 10.0;
        };
        colors = {
          background = "#0A0E14";
          statusline = "#FFFFFF";
        };
      }
    ];

    gaps = {
      smartGaps = false;
      inner = 10;
    };

    floating.border = 0;
    window.border= 0;
    
    keybindings = lib.mkOptionDefault {
      "${modifier}+q" = "kill";
      "Print" = "exec grim ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png";
      "Shift+Print" = "exec grim -g '$(slurp)'' ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png";
      "${modifier}+Print" = ''exec sh -c 'grim -g "$(swaymsg -t get_tree | jq -j '"'"'.. | select(.type?) | select(.focused).rect | "\(.x),\(.y) \(.width)x\(.height)"'"'"')" ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png' '';
      "${modifier}+Shift+f" = "exec alacritty -e ranger";
      "${modifier}+Shift+d" = "exec emote";
    };
  };
}
