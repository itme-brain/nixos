{ config, pkgs, lib, ... }:

{
  users.users.bryan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "home-manager" "input" "video" "audio" "kvm" "libvirtd" ]; 
  };

  security.sudo.wheelNeedsPassword = false;
}
