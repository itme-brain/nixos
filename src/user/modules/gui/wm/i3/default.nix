{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.wm.sway;
  modifier = config.wayland.windowManager.sway.config.modifier;

  wallpaper = builtins.fetchurl {
    url = "https://images6.alphacoders.com/117/1174033.png";
    sha256 = "1ph5m9s57076jx6042iipqx2ifzadmd5z4lf5l49wgq4jb92mp16";
  };

  barStatus = pkgs.writeShellScript "status.sh" ''
    #!/usr/bin/env bash
    while :; do 
      echo "$(ip -4 addr show eno1 | awk '/inet / {print $2}' | cut -d'/' -f1) | $(free -h | awk '/^Mem/ {print $3}') | $(date +'%I:%M:%S %p') | $(date +'%m-%d-%Y')"; sleep 1; 
    done
  '';

in
{ options.modules.user.gui.wm.i3 = { enable = mkEnableOption "Enable i3 WM"; };
  config = mkIf cfg.enable {
    xsession = {
      enable = true;
      windowManager.i3 = {
        config = {
          defaultWorkspace = "workspace number 1";

          fonts = {
            names = [ "Terminus" ];
          };

          modifier = "Mod1";
          menu = "rofi -show drun -show-icons -drun-icon-theme Qogir -font 'Noto Sans 14'";
          terminal = "${pkgs.alacritty}/bin/alacritty";

          bars = [
            {
              position = "top";
              statusCommand = "${barStatus}";
              fonts = {
                names = [ "Terminus" ];
                size = 12.0;
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
            criteria = [
              {
                title = "Android Emulator";
              }
            ];
          };

          window = {
            titlebar = false;
            border= 0;
          };

          keybindings = lib.mkOptionDefault {
            "${modifier}+q" = "kill";
            "Print" = "exec grim ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png";
            "${modifier}+Shift+Print" = "exec grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png";
            "${modifier}+Print" = ''exec sh -c 'grim -g "$(swaymsg -t get_tree | jq -j '"'"'.. | select(.type?) | select(.focused).rect | "\(.x),\(.y) \(.width)x\(.height)"'"'"')" ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png' '';
            "${modifier}+Shift+f" = "exec alacritty -e sh -c 'EDITOR=nvim ranger'";
            "${modifier}+Shift+d" = "exec rofi -modi emoji -show emoji";
          };
        };

        extraConfig = ''
          exec_always ${pkgs.autotiling}/bin/autotiling -sr "1.61"
        '';
      };
    };

    programs.rofi = import ./config/rofi { inherit pkgs config lib; };

    home.file.".config/rofi" = {
      source = ./config/rofi/config;
      recursive = true;
    };
    
    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
        config.common.default = "*";
      };
    };

    gtk = {
      enable = true;
      theme.package = pkgs.juno-theme;
      theme.name = "Juno-ocean";
      iconTheme.package = pkgs.qogir-icon-theme;
      iconTheme.name = "Qogir";
    };

    qt = {
      enable = true;
      style.package = pkgs.juno-theme;
      platformTheme.name = "gtk";
    };

    home.packages = with pkgs; [
      pavucontrol
      xdg-utils
      wl-clipboard
      autotiling

      grim
      jq
      slurp

      ranger
      highlight

      terminus-nerdfont
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];

    programs = {
      imv.enable = true;
    };

    fonts.fontconfig.enable = true;
  };
}
