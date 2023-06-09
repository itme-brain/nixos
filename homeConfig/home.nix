{ ... }:

{
  programs.home-manager.enable = true;
  imports = [ (import ./modules) ];
  home.stateVersion = "22.11";

  home.username = "bryan";
  home.homeDirectory = "/home/bryan";

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
