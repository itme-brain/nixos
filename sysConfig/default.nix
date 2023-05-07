{ pkgs, ... }:

{
  # Nix requires default.nix to build the system properly.
  
  # Add or remove imports based on the modules in sysConfig/.
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
