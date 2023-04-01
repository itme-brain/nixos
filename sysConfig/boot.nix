{ config, pkgs, lib, ... }:

{
  boot = {
    loader = {
      grub = {
        enable = true;
	      useOSProber = true;
	      devices = [ "nodev" ];
	      efiSupport = true;
	      configurationLimit = 5;
      };

      efi = {
        canTouchEfiVariables = true;
      };
    }; 
  };
}
