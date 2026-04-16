{ inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
      (import ./modules/disko)
    inputs.home-manager.nixosModules.home-manager
    { home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ]; }
      (import ./modules/home-manager)
    ../../../user
    ../../keys
    ../../modules/sops
    ./hardware.nix
    ./system.nix
  ];
}
