{ lib, pkgs, config, ... }:

with lib;
  let cfg = config.modules.tor;
in
{ options.modules.tor = { enable = mkEnableOption "tor"; };
  config = mkIf cfg.enable {
    services = {
      tor = {
        enable = true;
      };
    };
  };
}
