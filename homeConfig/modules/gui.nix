{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.gui;
    modifier = config.wayland.windowManager.sway.config.modifier;

in {
    options.modules.gui = { enable = mkEnableOption "gui"; };
    config = mkIf cfg.enable {
      wayland.windowManager.sway = {
        enable = true;
        xwayland = true;
        wrapperFeatures.gtk = true;
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

          bars.sway-bar = {
            position = "top";
            statusCommand = ''while :; do echo "$(free -h | awk '/^Mem/ {print $3}') '|' $(date +'%I:%M:%S %p') '|' $(date +'%m-%d-%Y')"; sleep 1; done'';
            fonts = { 
              names = [ "Noto Sans" "Noto Emoji" "Noto Color Emoji" ];
              size = 10.0;
            };
            colors.background = "#0A0E14";
            colors.statusline = "#FFFFFF";
          };

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

          extraOptions = [
            "--unsupported-gpu"
            "--my-next-gpu-wont-be-nvidia"
          ];

          extraSessionCommands = ''
            export _JAVA_AWT_WM_NONREPARENTING=1
          '';
        };
      };
      
      gtk = {
        enable = true;
        theme.package = pkgs.juno-theme;
        theme.name = "Juno-ocean";
        iconTheme.package = pkgs.qogir-icon-theme;
        iconTheme.name = "Qogir";
      };

      programs.btop.enable = true;
      fonts.fontconfig.enable = true;

      programs.rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        location = "center";
        terminal = "\${pkgs.alacritty}/bin/alacritty";

        theme = {
          "*" = {
            nord0 = mkLiteral "#2e3440";
            nord1 = mkLiteral "#3b4252";
            nord2 = mkLiteral "#434c5e";
            nord3 = mkLiteral "#4c566a";
            nord4 = mkLiteral "#d8dee9";
            nord5 = mkLiteral "#e5e9f0";
            nord6 = mkLiteral "#eceff4";
            nord7 = mkLiteral "#8fbcbb";
            nord8 = mkLiteral "#88c0d0";
            nord9 = mkLiteral "#81a1c1";
            nord10 = mkLiteral "#5e81ac";
            nord11 = mkLiteral "#bf616a";
            nord12 = mkLiteral "#d08770";
            nord13 = mkLiteral "#ebcb8b";
            nord14 = mkLiteral "#a3be8c";
            nord15 = mkLiteral "#b48ead";
            spacing = 2;
            background-color = mkLiteral "var(nord1)";
            background = mkLiteral "var(nord1)";
            foreground = mkLiteral "var(nord4)";
            normal-background = mkLiteral "var(background)";
            normal-foreground = mkLiteral "var(foreground)";
            alternate-normal-background = mkLiteral "var(background)";
            alternate-normal-foreground = mkLiteral "var(foreground)";
            selected-normal-background = mkLiteral "var(nord8)";
            selected-normal-foreground = mkLiteral "var(background)";
            active-background = mkLiteral "var(background)";
            active-foreground = mkLiteral "var(nord10)";
            alternate-active-background = mkLiteral "var(background)";
            alternate-active-foreground = mkLiteral "var(nord10)";
            selected-active-background = mkLiteral "var(nord10)";
            selected-active-foreground = mkLiteral "var(background)";
            urgent-background = mkLiteral "var(background)";
            urgent-foreground = mkLiteral "var(nord11)";
            alternate-urgent-background = mkLiteral "var(background)";
            alternate-urgent-foreground = mkLiteral "var(nord11)";
            selected-urgent-background = mkLiteral "var(nord11)";
            selected-urgent-foreground = mkLiteral "var(background)";
          };
          
          element = {
            padding = mkLiteral "0px 0px 0px 7px";
            spacing = mkLiteral "5px";
            border = 0;
            cursor = mkLiteral "pointer";
          };

          "element normal.normal" = {
            background-color = mkLiteral "var(normal-background)";
            text-color = mkLiteral "var(normal-foreground)";
          };

          "element normal.urgent" = {
            background-color = mkLiteral "var(urgent-background)";
            text-color = mkLiteral "var(urgent-foreground)";
          };

          "element normal.active" = {
            background-color = mkLiteral "var(active-background)";
            text-color = mkLiteral "var(active-foreground)";
          };

          "element selected.normal" = {
            background-color = mkLiteral "var(selected-normal-background)";
            text-color = mkLiteral "var(selected-normal-foreground)";
          };

          "element selected.urgent" = {
            background-color = mkLiteral "var(selected-urgent-background)";
            text-color = mkLiteral "var(selected-urgent-foreground)";
          };

          "element selected.active" = {
            background-color = mkLiteral "var(selected-active-background)";
            text-color = mkLiteral "var(selected-active-foreground)";
          };

          "element alternate.normal" = {
            background-color = mkLiteral "var(alternate-normal-background)";
            text-color = mkLiteral "var(alternate-normal-foreground)";
          };

          "element alternate.urgent" = {
            background-color = mkLiteral "var(alternate-urgent-background)";
            text-color = mkLiteral "var(alternate-urgent-foreground)";
          };

          "element alternate.active" = {
            background-color = mkLiteral "var(alternate-active-background)";
            text-color = mkLiteral "var(alternate-active-foreground)";
          };

          "element-text" = {
            background-color = mkLiteral "rgba(0, 0, 0, 0%)";
            text-color = mkLiteral "inherit";
            highlight = mkLiteral "inherit";
            cursor = mkLiteral "inherit";
          };

          "element-icon" = {
            background-color = mkLiteral "rgba(0, 0, 0, 0%)";
            size = mkLiteral "1.0000em";
            text-color = mkLiteral "inherit";
            cursor = mkLiteral "inherit";
          };

          window = {
            padding = 0;
            border = 0;
            background-color = mkLiteral "var(background)";
          };

          mainbox = {
            padding = 0;
            border = 0;
          };

          message = {
            margin = mkLiteral "0px 7px";
          };

          textbox = {
            text-color = mkLiteral "var(foreground)";
          };

          listview = {
            margin = mkLiteral "0px 0px 5px";
            scrollbar = true;
            spacing = mkLiteral "2px";
            fixed-height = 0;
          };

          scrollbar = {
            padding = 0;
            handle-width = mkLiteral "14px";
            border = 0;
            handle-color = mkLiteral "var(nord3)";
          };

          button = {
            spacing = 0;
            text-color = mkLiteral "var(normal-foreground)";
            cursor = mkLiteral "pointer";
          };

          "button selected" = {
            background-color = mkLiteral "var(selected-normal-background)";
            text-color = mkLiteral "var(selected-normal-foreground)";
          };

          inputbar = {
            padding = mkLiteral "7px";
            margin = mkLiteral "7px";
            spacing = 0;
            text-color = mkLiteral "var(normal-foreground)";
            background-color = mkLiteral "var(nord3)";
            children = [ "entry" ];
          };

          entry = {
            spacing = 0;
            cursor = mkLiteral "text";
            text-color = mkLiteral "var(normal-foreground)";
            background-color = mkLiteral "var(nord3)";
          };
        };
      };
    
      home.packages = [
        xdg-utils
        grim
        slurp

        imv
        gimp
        evince

        noto-fonts
        noto-fonts-cjk

        emote 
        emojione
      ];
    };
}
