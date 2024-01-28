{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.dev;

in
{ options.modules.dev = { enable = mkEnableOption "dev"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nix-init
      nix-prefetch-git

      glibc
      gcc

      docker
    ];
  };
}
