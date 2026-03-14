{ config, ... }:

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
