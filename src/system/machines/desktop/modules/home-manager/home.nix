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
        git.enable = true;

        security = {
          enable = true;
          gpg.enable = true;
        };

        utils = {
          enable = true;
          dev.enable = true;
          irc.enable = true;
          neovim.enable = true;
          vim.enable = false;
        };

        gui = {
          wm.sway.enable = true;
          alacritty.enable = true;
          browsers.enable = true;
          corn.enable = true;
          fun.enable = true;
          utils.enable = true;
          writing.enable = true;
        };
      };
    };
  };
}
