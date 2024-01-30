{ lib, pkgs, ... }:

{
  imports = [
    ../../user
    ./hardware.nix
    ./system.nix
  ];
}
