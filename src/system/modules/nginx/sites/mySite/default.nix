{ lib, config, ... }:

with lib;
let
  cfg = config.modules.system.nginx.mySite;
  nginxCfg = config.modules.system.nginx;

in
{ options.modules.system.nginx.mySite = { enable = mkEnableOption "system.nginx.mySite"; };
  config = mkIf (cfg.enable && nginxCfg) {
    security.acme = {
      certs = {
        "*.ramos.codes" = {
          #TODO: configure ACME certs
        };
      };
    };
    services.nginx = {
      #TODO: check if configure as vhost or stream
      virtualHosts = {
        "*.ramos.codes" = {
          addSSL = true;
          onlySSL = true;
          forceSSL = true;
          acmeRoot = null;
        };
      };
    };
  };
}
