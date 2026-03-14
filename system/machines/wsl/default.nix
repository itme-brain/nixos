{ inputs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
      (import ./modules/wsl)
    inputs.home-manager.nixosModules.home-manager
      (import ./modules/home-manager)
    ../../../user
    ../../keys
    ./system.nix
  ];
}
