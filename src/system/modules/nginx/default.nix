{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.nginx;
  module = config.modules.system;
  forgejo = config.services.forgejo;

in
{ options.modules.system.nginx = { enable = mkEnableOption "Nginx Reverse Proxy"; };
  config = mkIf cfg.enable {
    users = {
      users = {
        "${config.services.nginx.user}" = {
          description = "Web server system user";
          isSystemUser = true;
          group = mkForce "${config.services.nginx.group}";
          extraGroups = [
            "${config.security.acme.defaults.group}"
          ];
        };
        "btc" = {
          extraGroups = mkIf module.bitcoin.enable [
            "${config.services.nginx.group}"
          ];
        };
        "${forgejo.user}" = {
          extraGroups = mkIf module.forgejo.enable [
            "${config.services.nginx.group}"
          ];
        };
      };
      groups = {
        "${config.services.nginx.group}" = {
          members = [
            "${config.services.nginx.user}"
          ];
        };
      };
    };

    security.acme = 
    {
      acceptTerms = true;
      defaults = {
        email = "${config.user.email}";
        validMinDays = 90;
        listenHTTP = ":80";
      };
      certs = {
        "ramos.codes" = {
          extraDomainNames = attrNames config.services.nginx.virtualHosts;
        };
      };
    };

    services.nginx = {
      enable = true;
      user = "nginx";
      group = "web";
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

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
              proxyPass = "http://unix:${forgejo.settings.server.HTTP_ADDR}";
            };
          };
        };
        #"btc.ramos.codes" = mkIf module.bitcoin.electrum.enable {
        #  locations = {
        #   "/" = {
        #     proxyPass = "";
        #   };
        #  };
        #};
      };
    };
  };
}
