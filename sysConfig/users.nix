{ config, pkgs, lib, ... }:

{
  # Change users.users.<USERNAME> to your username, I don't recommend messing with extraGroups
  users.users.bryan = {
  isNormalUser = true;
  extraGroups = [ "wheel" "networkmanager" "home-manager" "input" "video" "audio" "kvm" "libvirtd" ]; 
  };

  security.sudo.wheelNeedsPassword = false; # Feel free to remove this if you want to type your password on sudo
  
  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

}
