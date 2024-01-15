{ lib, pkgs, config, ... }:

with lib;
  let cfg = config.modules.nginx;
in
{ options.modules.nginx = { enable = mkEnableOption "nginx"; };
  config = mkIf cfg.enable {
    services = {
      nginx = {
        enable = true;
        streamConfig = import ./config/stream.nix;
      };
    };
  };
}
