{ ... }:

{
  imports = [
    ../../../user/config
    ./hardware.nix
    ./system.nix
    ./modules/disko
  ];
}
