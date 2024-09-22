{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.wm.hyprland;

  wallpapers = builtins.path {
    path = ./config/wallpapers;
    name = "wallpapers";
  };

in
{ options.modules.user.gui.wm.hyprland = { enable = mkEnableOption "Enable hyprland module"; };
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
          "DP-1, 1920x1080, 1920x0, 1"
        ];

        exec-once = [
          "waybar"
        ];

        bind = [
          "$mod, Return, exec, $terminal"
          "$mod, q, killactive"

          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"

          "$mod&SHIFT, J, movewindow, d"
          "$mod&SHIFT, K, movewindow, u"
          "$mod&SHIFT, H, movewindow, l"
          "$mod&SHIFT, L, movewindow, r"

          "$mod, F, fullscreen"

          ", Print, exec, grim ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png"
          "SHIFT, Print, exec, grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png"
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
          "float, title: Extension: (PassFF)"
        ];

        general = {
          layout = "master";
          border_size = 0;
        };

        decoration = {
          rounding = 10;
        };

        master = {
          drop_at_cursor = false;
          #new_is_master = false;
        };

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          accel_profile = "flat";
          sensitivity = 0;
        };

        env = [
          "HYPRCURSOR_SIZE, 24"
          "GTK_THEME, Juno-ocean"

          "LIBVA_DRIVER_NAME,nvidia"
          "XDG_SESSION_TYPE,wayland"
          "GBM_BACKEND,nvidia-drm"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
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

    home = {
      file = {
        ".config/rofi" = {
          source = ./config/rofi/config;
          recursive = true;
        };
        ".config/waybar" = {
          source = ./config/waybar;
          recursive = true;
        };
      };

      packages = with pkgs; [
        pavucontrol
        xdg-utils
        wl-clipboard
        cliphist

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

      sessionVariables = {
        NIXOS_OZONE_WL = 1;
      };
    };

    programs.waybar = {
      enable = true;
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
        name = "Juno-ocean";
        package = pkgs.juno-theme;
      };
      iconTheme = {
        name = "Qogir";
        package = pkgs.qogir-icon-theme;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    qt = {
      enable = true;
      style = {
        name = "juno-ocean";
        package = pkgs.juno-theme;
      };
      platformTheme.name = "gtk";
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
      ];
      config.common.default = "*";
    };

    programs = {
      imv.enable = true;
    };

    fonts.fontconfig.enable = true;
  };
}
