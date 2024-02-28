{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.utils.dev;

in
{ options.modules.utils.dev = { enable = mkEnableOption "utils.dev"; };
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
