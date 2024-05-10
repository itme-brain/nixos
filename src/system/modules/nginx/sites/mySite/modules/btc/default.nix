{ lib, config, ... }:

with lib;
let
  cfg = config.modules.system.nginx.mySite.btc;
  mySiteCfg = config.modules.system.nginx.mySite;
  btcCfg = config.modules.system.bitcoin;

in
{ options.modules.system.nginx.mySite.btc = { enable = mkEnableOption "system.nginx.mySite.btc"; };
  config = mkIf (cfg.enable && mySiteCfg && btcCfg) {
    #security.acme = {
    #  certs = {
    #    "btc.ramos.codes" = {
    #      #TODO: configure ACME certs
    #    };
    #  };
    #};
    #services.nginx = {
    #  #TODO: check if configure as vhost or stream
    #  virtualHosts = {
    #    "btc.ramos.codes" = {
    #      addSSL = true;
    #      onlySSL = true;
    #      forceSSL = true;
    #      acmeRoot = null;
    #    };
    #  };
    #};
  };
}
