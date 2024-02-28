{ lib, pkgs, config, ... }:

with lib;
  let
    cfg = config.modules.corn.sparrow-server;
    sparrow-server = import ./derivation.nix { inherit pkgs; };
in
{ options.modules.corn.sparrow-server = { enable = mkEnableOption "corn.sparrow-server"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sparrow-server
    ];
  };
}
