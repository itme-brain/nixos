{ config, pkgs, ... }:

{
  imports = [ ../../../user ];

  home = {
    stateVersion = "23.11";
    username = "${config.user.name}";
    homeDirectory = "/home/${config.user.name}";
    programs.home-manager.enable = true;

    programs.bash = {
      initExtra =
        import ./scripts/guiControl
      ;
    };

    nix = {
      package = pkgs.nixFlakes;
      extraOptions = "experimental-features = nix-command flakes";
      settings = {
        auto-optimise-store = true;
        trusted-users = [ "${config.user.name}" ];
      };
    };

    modules = {
      user = {
        bash.enable = true;
        git.enable = true;

        security= {
          gpg.enable = true;
        };

        gui = {
          wm.sway.enable = true;
          alacritty.enable = true;
          browsers.enable = true;
          neovim.enable = true;
        };
        utils = {
          enable = true;
          dev.enable = true;
          email.enable = true;
          irc.enable = true;
          vim.enable = true;
        };
      };
    };
  };
}
