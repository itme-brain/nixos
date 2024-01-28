{ config, ... }:

{
  programs.home-manager.enable = true;

  imports = [ ./modules ../user ];

  home.stateVersion = "22.11";

  home.username = "${config.user.name}";
  home.homeDirectory = "/home/${config.user.name}";

  modules = {
    bash.enable = true;
    git.enable = true;
    gpg.enable = true;
    gui.enable = true;
    security.enable = true;
    utils.enable = true;
  };
}
