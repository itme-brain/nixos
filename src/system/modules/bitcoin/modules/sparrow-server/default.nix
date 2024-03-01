{ lib, pkgs, config, ... }:

with lib;
  let
    cfg = config.modules.system.bitcoin.sparrow-server;
    sparrow-server = import ./derivation.nix { inherit pkgs; };
in
{ options.modules.system.bitcoin.sparrow-server = { enable = mkEnableOption "system.bitcoin.sparrow-server"; };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sparrow-server
    ];
  };
}
