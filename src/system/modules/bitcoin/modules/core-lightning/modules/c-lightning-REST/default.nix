{ lib, pkgs, config, ... }:

with lib;
  let
    cfg = config.modules.system.bitcoin.core-lightning.REST;
    cln = config.modules.system.bitcoin.core-lightning;
    c-lightning-REST = import ./derivation.nix { inherit pkgs; };

in
{ options.modules.system.bitcoin.core-lightning.REST = {
    enable = mkEnableOption "system.bitcoin.core-lightning.REST";
  };
  config = mkIf (cfg.enable && cln.enable) {
    environment.systemPackages = with pkgs; [
      c-lightning-REST
    ];
  };
}
