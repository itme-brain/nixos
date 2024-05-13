{ lib, pkgs, config, ... }:

with lib;
let
  btc = config.modules.system.bitcoin;
  cfg = btc.sparrow-server;

in
{ options.modules.system.bitcoin.sparrow-server = { enable = mkEnableOption "bitcoin.sparrow-server"; };
  config = mkIf (cfg.enable && btc.enable) {
    nixpkgs.overlays = [
      (final: prev: {
        sparrow-server = prev.callPackage ./derivation.nix {};
      })
    ];
    environment.systemPackages = with pkgs; [
      sparrow-server
    ];
  };
}
