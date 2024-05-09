{ config, pkgs, ... }:

{
  imports = [ ../../../user ];

  home = {
    stateVersion = "23.11";
    username = "${config.user.name}";
    homeDirectory = "/home/${config.user.name}";

    file.".config/home-manager" = {
      source = ../../../..;
      recursive = true;
    };
  };

  programs.home-manager.enable = true;
  programs.bash.shellAliases = {
    nixup = "home-manager switch --flake";
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
      gpg.enable = true;
      security.enable = false;
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
  };
}
