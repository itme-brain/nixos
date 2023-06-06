{ user, ... }:

{ 
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  home = { 
    username = user;
    homeDirectory = "/home/${user}";
  };

}
