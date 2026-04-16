{ inputs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
      (import ./modules/wsl)
    inputs.home-manager.nixosModules.home-manager
    { home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ]; }
      (import ./modules/home-manager)
    ../../../user
    ../../keys
    ../../modules/sops
    ./system.nix
  ];
}
