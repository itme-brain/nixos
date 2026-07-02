{ pkgs, lib, config, monitors ? [], ... }:

with lib;
let
  cfg = config.modules.user.gui.wm.hyprland;

  wallpaper = builtins.fetchurl {
    url = "https://images6.alphacoders.com/117/1174033.png";
    sha256 = "1ph5m9s57076jx6042iipqx2ifzadmd5z4lf5l49wgq4jb92mp16";
  };

  toLua = lib.generators.toLua {};

  toLuaMonitor = m: ''
    hl.monitor({
      output = ${toLua m.name},
      mode = ${toLua "${toString m.width}x${toString m.height}@${toString m.refreshRate}"},
      position = ${toLua "${toString m.x}x${toString m.y}"},
      scale = ${toLua m.scale},
    })
  '';

  monitorConfig = if monitors != []
    then concatMapStrings toLuaMonitor monitors
    else ''
      hl.monitor({
        output = "",
        mode = "preferred",
        position = "auto",
        scale = 1,
      })
    '';

  workspaceBinds = concatMapStrings (x:
    let
      workspace = x + 1;
      key = toString (mod workspace 10);
    in
    ''
      hl.bind(mod .. ${toLua " + ${key}"}, hl.dsp.focus({ workspace = ${toString workspace} }))
      hl.bind(mod .. ${toLua " + SHIFT + ${key}"}, hl.dsp.window.move({ workspace = ${toString workspace} }))
    ''
  ) (range 0 9);

in
{ options.modules.user.gui.wm.hyprland = { enable = mkEnableOption "Enable Hyprland WM"; };
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      xwayland.enable = true;

      settings = {};
      extraConfig = ''
        local mod = "ALT"
        local terminal = ${toLua "${pkgs.alacritty}/bin/alacritty"}
        local menu = "rofi -show drun -show-icons -drun-icon-theme Qogir -font 'Noto Sans 14'"

        ${monitorConfig}

        hl.env("HYPRCURSOR_THEME", "Vanilla-DMZ")
        hl.env("HYPRCURSOR_SIZE", "24")
        hl.env("GTK_THEME", "Juno")
        hl.env("LIBVA_DRIVER_NAME", "nvidia")
        hl.env("XDG_SESSION_TYPE", "wayland")
        hl.env("GBM_BACKEND", "nvidia-drm")
        hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

        hl.on("hyprland.start", function()
          hl.exec_cmd("waybar")
          hl.exec_cmd("hyprctl setcursor Vanilla-DMZ 24")
        end)

        hl.config({
          general = {
            layout = "master",
            border_size = 0,
          },
          decoration = {
            rounding = 10,
          },
          master = {
            drop_at_cursor = false,
          },
          input = {
            kb_layout = "us",
            follow_mouse = 1,
            accel_profile = "flat",
            sensitivity = 0.35,
          },
          cursor = {
            inactive_timeout = 0,
            no_hardware_cursors = 1,
            hide_on_touch = false,
            use_cpu_buffer = 0,
            enable_hyprcursor = false,
          },
        })

        hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
        hl.bind(mod .. " + q", hl.dsp.window.close())

        hl.bind(mod .. " + J", hl.dsp.focus({ direction = "d" }))
        hl.bind(mod .. " + K", hl.dsp.focus({ direction = "u" }))
        hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }))
        hl.bind(mod .. " + L", hl.dsp.focus({ direction = "r" }))

        hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
        hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
        hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
        hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))

        hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
        hl.bind("Print", hl.dsp.exec_cmd("grim ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png"))
        hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png"))
        hl.bind(mod .. " + SHIFT + F", hl.dsp.exec_cmd("alacritty -e sh -c 'EDITOR=nvim ranger'"))
        hl.bind("SHIFT + Print", hl.dsp.exec_cmd(${toLua ''grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png''}))
        hl.bind(mod .. " + D", hl.dsp.exec_cmd(menu))
        hl.bind(mod .. " + SHIFT + D", hl.dsp.exec_cmd("rofi -modi emoji -show emoji"))
        hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })

        ${workspaceBinds}

        hl.window_rule({
          match = { title = "^(Android Emulator)" },
          float = true,
        })
        hl.window_rule({
          match = { title = " Extension: (PassFF)" },
          float = true,
        })
        hl.window_rule({
          match = { class = "sys-specs" },
          float = true,
          size = { 400, 600 },
          stay_focused = true,
        })
      '';
    };

    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
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
        pulsemixer
        xdg-utils
        wl-clipboard
        cliphist

        dconf

        grim
        jq
        slurp

        ranger
        highlight

        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
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
          [ "${wallpaper}" ];

        wallpaper = [
          ",${wallpaper}"
        ];
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "Juno";
        package = pkgs.juno-theme;
      };
      iconTheme = {
        name = "Qogir";
        package = pkgs.qogir-icon-theme;
      };
      cursorTheme = {
        package = pkgs.vanilla-dmz;
        name = "Vanilla-DMZ";
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
        name = "juno";
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
      mpv.enable = true;
      zathura.enable = true;
    };

    fonts.fontconfig.enable = true;

    # Auto-start Hyprland on tty1
    programs.bash.profileExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
  };
}
