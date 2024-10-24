{ config, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${config.user.name} = {
    imports = [ ../../../../../user ];

    programs.home-manager.enable = true;

    home.stateVersion = "23.11";

    home.username = "${config.user.name}";
    home.homeDirectory = "/home/${config.user.name}";

    modules = {
      user = {
        bash.enable = true;

        dev = {
          enable = true;
          git.enable = true;
          neovim = {
            lazy.enable = true;
            lazyvim.enable = false;
          };
          vim.enable = false;
        };

        security = {
          enable = true;
          gpg.enable = true;
        };

        tmux.enable = true;

        utils = {
          enable = true;
          irc.enable = true;
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
