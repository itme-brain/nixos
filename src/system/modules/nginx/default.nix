{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.nginx;
  module = config.modules.system;

in
{ options.modules.system.nginx = { enable = mkEnableOption "Nginx Reverse Proxy"; };
  config = mkIf cfg.enable {
    users = {
      users = {
        "nginx" = {
          description = "Web server system user";
          isSystemUser = true;
          group = mkForce "web";
        };
        "btc" = {
          extraGroups = mkIf module.bitcoin.enable [
            "web"
          ];
        };
        "git" = {
          extraGroups = mkIf module.forgejo.enable [
            "web"
          ];
        };
      };
      groups = {
        "web" = {
          members = [
            "nginx"
          ];
        };
      };
    };

    security.acme = 
    let
      acmeDir = "/var/lib/acme";
    in
    {
      acceptTerms = true;
      certs = {
        "ramos.codes" = {
          #webroot = "${acmeDir}/acme-challenge";
          directory = "${acmeDir}/ramos.codes";
          email = config.user.email;
          group = "web";
          validMinDays = 90;
          extraDomainNames = attrNames config.services.nginx.virtualHosts;
          listenHTTP = ":80";
        };
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts = 
      let
        certPath = config.security.acme.certs."ramos.codes".directory;
        sslCertificate = "${certPath}/fullchain.pem";
        sslCertificateKey = "${certPath}/key.pem";

        withSSL = hosts: mapAttrs (name: hostConfig: hostConfig // {
          inherit sslCertificate sslCertificateKey;
          forceSSL = true;
        }) hosts;

      in withSSL
      {
        "git.ramos.codes" = mkIf module.forgejo.enable {
          locations = {
            "/" = {
              proxyPass = "http://unix:${config.services.forgejo.settings.server.HTTP_ADDR}";
            };
          };
        };
        #"btc.ramos.codes" = mkIf module.bitcoin.enable {
        #  locations = {
        #  };
        #};
      };
    };
  };
}
