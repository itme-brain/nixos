{ config, ... }:

{
  programs.home-manager.enable = true;
  programs.bash.shellAliases = {
    nixup = "sudo nixos-rebuild switch --flake .#windows";
  };

  imports = [
    ../../modules
    ../../user
  ];

  home.stateVersion = "23.11";

  home.username = "${config.user.name}";
  home.homeDirectory = "/home/${config.user.name}";

  modules = {
    bash.enable = true;
    git.enable = true;
    gpg.enable = true;
    gui.enable = false;
    security.enable = true;
    utils = {
      enable = true;
      dev.enable = true;
      email.enable = true;
      irc.enable = true;
      vim.enable = true;
    };
  };
}
