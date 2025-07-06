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

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "${config.user.email}";
        validMinDays = 90;
        listenHTTP = ":80";
      };
      certs = {
        "ramos.codes" = {
          extraDomainNames = [
            "git.ramos.codes"
            "btc.ramos.codes"
          ];
        };
      };
    };

    services.nginx = 
    let
      certPath = config.security.acme.certs."ramos.codes".directory;
      sslCertificate = "${certPath}/fullchain.pem";
      sslCertificateKey = "${certPath}/key.pem";

      withSSL = hosts: mapAttrs (name: hostConfig: hostConfig // {
        inherit sslCertificate sslCertificateKey;
        forceSSL = true;
      }) hosts;
    in
    {
      enable = true;
      user = "nginx";
      group = "web";
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = withSSL {
        "git.ramos.codes" = mkIf module.forgejo.enable {
          locations = {
            "/" = {
              proxyPass = "http://unix:${forgejo.settings.server.HTTP_ADDR}";
            };
          };
        };
      };

      streamConfig = ''
        ${lib.optionalString module.bitcoin.electrum.enable ''
          server {
            listen 0.0.0.0:50002 ssl;
            proxy_pass 127.0.0.1:50001;

            ssl_certificate ${sslCertificate};
            ssl_certificate_key ${sslCertificateKey};
          }
        ''}
      '';
    };
    networking.firewall.allowedTCPPorts = [
      50002
    ];
  };
}
