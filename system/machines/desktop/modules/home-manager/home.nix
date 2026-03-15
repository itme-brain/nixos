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

    systemd.user.services.nvr-mount = {
      Unit = {
        Description = "Mount Frigate recordings via SSHFS";
        After = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Media/nvr";
        ExecStart = "${pkgs.sshfs}/bin/sshfs -o reconnect,ServerAliveInterval=15 server:/var/lib/frigate %h/Media/nvr";
        ExecStop = "${pkgs.fuse}/bin/fusermount -u %h/Media/nvr";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          serverAliveInterval = 60;
          serverAliveCountMax = 3;
        };
        "server" = {
          hostname = "192.168.0.154";
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
