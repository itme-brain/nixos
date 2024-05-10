{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.system.nginx;

in
{ options.modules.system.nginx = { enable = mkEnableOption "system.nginx"; };
  config = mkIf cfg.enable {
    imports = [ ./sites ];
    security.acme = {
      defaults = {
        email = config.user.email;
      };
    };
    services.nginx = {
      enable = true;
      package = pkgs.nginxMainLine;
    };
  };
}
