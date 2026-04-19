{ inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ../../../user
    ../../keys
    ./hardware.nix
    ./system.nix
    ./modules/kiosk
  ];
}