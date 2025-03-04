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

        tmux.enable = true;

        utils = {
          enable = true;
          dev = {
            enable = true;
          };
          email.enable = true;
          neovim.enable = true;
          vim.enable = true;
        };

        gui = {
          wm.i3.enable = true;

          browser = {
            chromium.enable = true;
          };

          alacritty.enable = true;
          utils.enable = true;
          writing.enable = true;
        };
      };
    };
  };
}
