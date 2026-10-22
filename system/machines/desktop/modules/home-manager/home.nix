{ config, pkgs, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    monitors = config.monitors;
  };
  home-manager.users.${config.user.name} = {
    imports = [
      ../../../../../user
      ../../../../../user/home.nix
      ../../../../../user/modules
    ];

    home.stateVersion = "23.11";

    home.packages = [ pkgs.sshfs ];

    # Disabled: server:/var/lib/frigate/recordings is not accessible (Permission
    # denied -- frigate.enable = false on the server), so this unit failed every
    # boot and made login wait on it. Re-enable once the Frigate path exists again.
    # systemd.user.services.nvr-mount = {
    #   Unit = {
    #     Description = "Mount Frigate recordings via SSHFS";
    #     After = [ "network-online.target" ];
    #   };
    #   Service = {
    #     Type = "oneshot";
    #     RemainAfterExit = true;
    #     ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Media/nvr";
    #     ExecStart = "${pkgs.sshfs}/bin/sshfs -o reconnect,ServerAliveInterval=15 server:/var/lib/frigate/recordings %h/Media/nvr";
    #     ExecStop = "${pkgs.fuse}/bin/fusermount -u %h/Media/nvr";
    #   };
    #   Install = {
    #     WantedBy = [ "default.target" ];
    #   };
    # };

    # Hardened: sshfs now runs in the foreground (-f) so systemd actually
    # supervises the mount, and auto_unmount guarantees the FUSE mountpoint is
    # torn down if sshfs dies instead of being left dangling (a dead FUSE mount
    # puts every process that touches it into uninterruptible sleep, which shows
    # up as high load + idle CPU + heavy i/O pressure). Metadata caches are
    # raised a little because this directory holds >1M files over the network.
    systemd.user.services.comfy-mount = {
      Unit = {
        Description = "Mount ComfyUI outputs via SSHFS";
        After = [ "network-online.target" ];
        # Was only After=, so the mount could be attempted before the network
        # was actually up and fail at login.
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "exec";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Media/Comfy";
        ExecStart = "${pkgs.sshfs}/bin/sshfs -f -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,auto_unmount,entry_timeout=5,attr_timeout=5,dcache_timeout=60,auto_cache rigby:/home/comfy/ComfyUI/output %h/Media/Comfy";
        # Supervised now, so a dropped Wi-Fi link or a restarted rigby
        # self-heals rather than leaving a dead mount behind.
        Restart = "on-failure";
        RestartSec = 10;
        # Don't let an unreachable rigby stall login for the 90s default.
        TimeoutStartSec = 20;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          serverAliveInterval = 60;
          serverAliveCountMax = 3;
        };
        "server" = {
          hostname = "192.168.0.154";
          user = "bryan";
        };
        "rigby" = {
          hostname = "192.168.0.23";
          user = "bryan";
        };
      };
    };

    # Machine-specific modules
    modules.user = {
      vim.enable = false;
      security.yubikey.enable = true;

      utils = {
        dev.enable = true;
        irc.enable = true;
        writing.enable = true;
      };

      pi = {
        enable = true;
      };

      gui = {
        wm.hyprland.enable = true;
        browser.firefox.enable = true;
        alacritty.enable = true;
        corn.enable = true;
        fun.enable = true;
        utils.enable = true;
      };
    };
  };
}
