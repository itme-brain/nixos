{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.modules.system.bitcoin.core-lightning.REST;
  cln = config.modules.system.bitcoin.core-lightning;

in
{ options.modules.system.bitcoin.core-lightning.REST = { enable = mkEnableOption "system.bitcoin.core-lightning.REST"; };
  config = mkIf (cfg.enable && cln.enable) {
    nixpkgs.overlays = [
      (final: prev: {
        c-lightning-REST = prev.callPackage ./derivation.nix {};
      })
    ];

    environment.systemPackages = with pkgs; [
      c-lightning-REST
    ];
  };
}
