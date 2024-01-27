{ config, ... }:

{
  programs.home-manager.enable = true;

  imports = [ ./modules ../user ];

  home.stateVersion = "22.11";

  home.username = "${config.user.name}";
  home.homeDirectory = "/home/${config.user.name}";

  modules = {
    gui.enable = true;
    browsers.enable = true;
    alacritty.enable = true;
    fun.enable = true;

    bash.enable = true;
    git.enable = true;
    gpg.enable = true;
    neovim.enable = true;

    utils.enable = true;
    security.enable = true;
    corn.enable = true;
  };
}
