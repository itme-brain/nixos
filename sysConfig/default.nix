{ pkgs, ... }:

{
  # Nix requires default.nix to build the system properly, do not rename it.
  
  # Add or remove imports based on the modules in your sysConfig directory.
  imports = [
	./audio.nix
	./boot.nix
	./gui.nix
	./hardware.nix
	./locale.nix
	./network.nix
	./users.nix
	./virt.nix
  ];

  # Enable nix commands and flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  system.stateVersion = "22.11"; # Do not edit this variable.
}
