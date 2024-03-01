{ lib, config, ... }:

with lib;
let
  cfg = config.modules.system.nginx.mySite.git;
  mySiteCfg = config.modules.system.nginx.mySite;

in
{ options.modules.system.nginx.mySite.git = { enable = mkEnableOption "system.nginx.mySite.git"; };
  config = mkIf (cfg.enable && mySiteCfg) {
    #security.acme = {
    #  certs = {
    #    "ramos.codes" = {
    #      #TODO: configure ACME certs
    #    };
    #  };
    #};
    #services.nginx = {
    #  #TODO: check if configure as vhost or stream
    #  streamConfig = services.nginx.streamConfig ++ {
    #    "*.ramos.codes" = {
    #      addSSL = true;
    #      onlySSL = true;
    #      forceSSL = true;
    #      acmeRoot = null;
    #    };
    #  };
    #};
  };
}
