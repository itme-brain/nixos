{ inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
      (import ./modules/disko)
    inputs.home-manager.nixosModules.home-manager
      (import ./modules/home-manager)
    ../../../user
    ../../keys
    ./hardware.nix
    ./system.nix
  ];
}
