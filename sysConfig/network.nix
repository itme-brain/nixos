{ config, pkgs, lib, ... }:

{

  networking = {
    hostName = "socrates"; # Change your hostname

    useDHCP = lib.mkDefault true;
    
    networkmanager.enable = true;
  };

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
