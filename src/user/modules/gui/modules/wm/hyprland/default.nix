{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.wm.hyprland;

  wallpapers = builtins.path {
    path = ./config/wallpapers;
    name = "wallpapers";
  };

in
{ options.modules.user.gui.wm.hyprland = { enable = mkEnableOption "Enable hyprland wm module"; };
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;

      settings = {
        "$mod" = "ALT";
        "$terminal" = "${pkgs.alacritty}/bin/alacritty";
        "$menu" = "rofi -show drun -show-icons -drun-icon-theme Qogir -font 'Noto Sans 14'";

        monitor = [
          "HDMI-A-1, 1920x1080, 0x0, 1"
          "DP-1, 1080x1920, 1920x0, 1, transform, 1"
        ];

        exec-once = [
          "waybar"
        ];

        bind = [
          "$mod, Enter, $terminal"
          "$mod, q, killactive"

          "$mod, J, swapwindow, d"
          "$mod, K, swapwindow, u"
          "$mod, H, swapwindow, l"
          "$mod, L, swapwindow, r"

          "$mod, F, fullscreen"

          ", Print, exec, grim ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png"
          "SHIFT, Print, exec, grim -g \"$slurp)\" ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png"
          "$mod&SHIFT, F, exec, alacritty -e sh -c 'EDITOR=nvim ranger'"
          #''$mod&SHIFT, Print, exec, sh -c 'grim -g "$(swaymsg -t get_tree | jq -j '"'"'.. | select(.type?) | select(.focused).rect | "\(.x),\(.y) \(.width)x\(.height)"'"'"')" ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png'"''

          "$mod, D, exec, $menu"
          "$mod&SHIFT, D, exec, rofi -modi emoji -show emoji"
        ] ++ ( builtins.concatLists (builtins.genList (
        x: let
          ws = let
            c = (x + 1) / 10;
            in
              builtins.toString (x + 1 - (c * 10));
        in
        [
          "$mod, ${ws}, workspace, ${toString (x + 1)}"
          "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
        ])
          10)
        );

        bindm = [
          "$mod, mouse:272, movewindow"
        ];

        windowrulev2 = [
          "float, title:(Android Emulator)"
        ];

        input = {
          kb_layout = "us";
          follow_mouse = 0;
          accel_profile = "flat";
          sensitivity = 0.65;
        };

        env = [
          "HYPRCURSOR_SIZE, 24"
          "GTK_THEME, Qogir"

          #"LIBVA_DRIVER_NAME, nvidia"
          #"XDG_SESSION_TYPE, wayland"
          #"GBM_BACKEND, nvidia-drm"
          #"__GLX_VENDOR_LIBRARY_NAME, nvidia"
          #"NVD_BACKEND, direct"
        ];
      };
    };

    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      location = "center";
      terminal = "alacritty";
      plugins = with pkgs; [
        rofi-emoji
      ];
    };
    home.file.".config/rofi" = {
      source = ./config/rofi/config;
      recursive = true;
    };


    programs.waybar = {
      enable = true;
      settings = [
        {
          mainBar = {
            font-family = "Terminus";
            font-size = 12;
            background-color = "rgba(10, 14, 20, 1)";
            color = "#FFFFFF";

            layer = "top";
            output = [
              "HDMI-A-1"
            ];

            position = "top";
            height = 10;

            modules-left = [
              "hyprland/workspaces"
              "wlr/taskbar"
            ];

            modules-center = [
              "clock"
            ];

            modules-right = [
              "memory"
              "network"
              "tray"
            ];

            "hyprland/workspaces" = {
              active-only = true;
              format = "{name}";
            };

            "wlr/taskbar" = {
              format = "{icon}";
              icon_size = 14;
              icon-theme = "Qogir";
              tooltip-format = "{title}";
              on-click = "minimize-raise";
              ignore-list = [
                "Alacritty"
                "rofi"
              ];
              rewrite = {
                "Firefox Web Browser" = "Firefox";
              };
            };

            "clock" = {
              format = "%I:%M:%S %p | %m-%d-%Y";
              interval = 60;
            };

            "memory" = {
              format = "RAM: {percentage}%";
              interval = 30;
            };

            "network" = {
              format-disconnected = "<span color=\"#FF0000\">󰜺</span>";
              format-wifi = "<span color=\"##00FF00\">󰖩</span>{essid}({signalStrength}%)";
              format-ethernet = "<span color=\"##00FF00\">󰈁</span>{cidr}";
            };

            "tray" = {
              icon_size = 16;
              spacing = 10;
            };
          };
        }
      ];
    };

    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        splash_offset = 2.0;

        preload =
          [ "${wallpapers}/${config.user.wallpaper}" ];

        wallpaper = [
          ",${wallpapers}/${config.user.wallpaper}"
        ];
      };
    };

    gtk = {
      enable = true;
      theme = {
        package = pkgs.juno-theme;
        name = "Juno-ocean";
      };
      iconTheme = {
        package = pkgs.qogir-icon-theme;
        name = "Qogir";
      };
    };

    qt = {
      enable = true;
      style.package = pkgs.juno-theme;
      platformTheme.name = "gtk";
    };

    xdg.portal.enable = true;

    home.packages = with pkgs; [
      pavucontrol
      xdg-utils
      wl-clipboard
      xdg-desktop-portal-hyprland
      dconf

      grim
      jq
      slurp

      ranger
      highlight

      terminus-nerdfont
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];

    programs = {
      imv.enable = true;
    };

    fonts.fontconfig.enable = true;
  };
}
