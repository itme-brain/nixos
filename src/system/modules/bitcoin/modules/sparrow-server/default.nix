{ lib, pkgs, config, ... }:

with lib;
  let
    cfg = config.modules.bitcoin.sparrow-server;
    sparrow-server = import ./derivation.nix { inherit pkgs; };
in
{ options.modules.bitcoin.sparrow-server = { enable = mkEnableOption "bitcoin.sparrow-server"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sparrow-server
    ];
  };
}
