{ config, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    monitors = config.monitors;
  };
  home-manager.users.${config.user.name} = {
    imports = [ ../../../../../user ];

    programs.home-manager.enable = true;

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

    home.stateVersion = "23.11";

    home.username = "${config.user.name}";
    home.homeDirectory = "/home/${config.user.name}";

    modules = {
      user = {
        bash.enable = true;
        git.enable = true;

        security = {
          enable = true;
          gpg.enable = true;
        };

        tmux.enable = true;

        utils = {
          enable = true;
          dev = {
            enable = true;
          };
          irc.enable = true;
          neovim.enable = true;
          vim.enable = false;
        };

        gui = {
          wm.hyprland.enable = true;

          browser = {
            firefox.enable = true;
          };

          alacritty.enable = true;
          corn.enable = true;
          fun.enable = true;
          utils.enable = true;
          writing.enable = true;
        };
      };
    };
  };
}
