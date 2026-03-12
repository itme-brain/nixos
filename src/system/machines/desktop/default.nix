{ ... }:

{
  imports = [
    ../../../user/config
    ../../config
    ./hardware.nix
    ./system.nix
    ./modules/disko
  ];
}
