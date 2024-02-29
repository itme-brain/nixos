{ lib, pkgs, config, ... }:

with lib;
  let
    cfg = config.modules.gui.bitcoin.sparrow-server;
    sparrow-server = import ./derivation.nix { inherit pkgs; };
in
{ options.modules.gui.bitcoin.sparrow-server = { enable = mkEnableOption "gui.bitcoin.sparrow-server"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sparrow-server
    ];
  };
}
