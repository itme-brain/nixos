{ config, pkgs, ... }:

{
  imports = [ ./user ];

  programs.home-manager.enable = true;

  home = {
    stateVersion = "23.11";
    username = "${config.user.name}";
    homeDirectory = "/home/${config.user.name}";

    file.".config/home-manager" = {
      source = ../../../..;
      recursive = true;
    };
  };

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes";
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "${config.user.name}" ];
    };
  };

  user = {
    bash.enable = true;
    git.enable = true;

    security= {
      gpg.enable = true;
    };

    gui = {
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

  programs.bash = {
    initExtra =
      import ./scripts/guiControl
    ;
  };
}
