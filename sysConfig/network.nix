{ config, pkgs, lib, ... }:

{

  networking = {
    hostName = "socrates"; # Change your hostname

    useDHCP = lib.mkDefault true;
    
    networkmanager.enable = true;
  };

  # Remove this if you don't want to use GPG as your SSH agent
  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
