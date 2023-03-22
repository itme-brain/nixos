{ config, pkgs, lib, ... }:

{

  networking = {
    hostName = "socrates";
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
