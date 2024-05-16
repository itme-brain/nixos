{ pkgs, lib, config, ... }:

{
  home.packages = with pkgs; [
    pass
    wireguard-tools
    ipscan
  ];
}
