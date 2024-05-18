{ config, lib, pkgs, ... }:

let
  modifier = config.wayland.windowManager.sway.config.modifier;
  wallpapers = builtins.path {
    path = ./wallpapers;
    name = "wallpapers";
  };

in
{ enable = true;
  xwayland = true;
  #wrapperFeatures.gtk = true;

  extraSessionCommands = ''
    export _JAVA_AWT_WM_NONREPARENTING=1
  '';

  config = {
    output = {
      HDMI-A-1 = {
        resolution = "1920x1080";
        position = "0,0";
        bg = "${wallpapers}/${config.user.wallpaper} fill";
      };
      DP-1 = {
        resolution = "1080x1920";
        position = "1920,0";
        transform = "90";
        bg = "${wallpapers}/${config.user.wallpaper} fill";
      };
    };
    modifier = "Mod1";
    menu = "rofi -show drun -show-icons -drun-icon-theme Qogir -font 'Noto Sans 14'";
    terminal = "${pkgs.alacritty}/bin/alacritty";

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
          names = [ "Noto Sans" ];
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

    floating = {
      titlebar = false;
      border = 0;
    };

    window = {
      titlebar = false;
      border= 0;
    };

    keybindings = lib.mkOptionDefault {
      "${modifier}+q" = "kill";
      "Print" = "exec grim ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png";
      "Shift+Print" = "exec grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png";
      "${modifier}+Print" = ''exec sh -c 'grim -g "$(swaymsg -t get_tree | jq -j '"'"'.. | select(.type?) | select(.focused).rect | "\(.x),\(.y) \(.width)x\(.height)"'"'"')" ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png' '';
      "${modifier}+Shift+f" = "exec alacritty -e sh -c 'EDITOR=nvim ranger'";
      "${modifier}+Shift+d" = "exec rofi -modi emoji -show emoji";
    };
  };

  extraConfig = ''
    for_window [app_id="one.alynx.showmethekey" title="Floating Window - Show Me The Key"] {
      floating enable
      sticky enable
    }
    exec_always ${pkgs.autotiling}/bin/autotiling
  '';
}
