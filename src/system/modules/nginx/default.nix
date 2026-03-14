{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.nginx;
  domain = "ramos.codes";

in
{
  options.modules.system.nginx = {
    enable = mkEnableOption "Nginx Reverse Proxy";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    systemd.services.nginx.serviceConfig.LimitNOFILE = 65536;

    security.acme = {
      acceptTerms = true;
      defaults.email = config.user.email;

      certs."${domain}" = {
        domain = "*.${domain}";
        dnsProvider = "namecheap";
        environmentFile = "/var/lib/acme/namecheap.env";
        group = "nginx";
      };
    };

    services.sslh = {
      enable = true;
      listenAddresses = [ "0.0.0.0" ];
      port = 443;
      settings = {
        protocols = [
          { name = "ssh"; host = "127.0.0.1"; port = "22"; }
          { name = "tls"; host = "127.0.0.1"; port = "4443"; }
        ];
      };
    };

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      eventsConfig = "worker_connections 4096;";

      # Catch-all default - friendly error for unknown subdomains
      virtualHosts."_" = {
        default = true;
        useACMEHost = domain;
        forceSSL = true;
        locations."/" = {
          return = "404 'Not Found: This subdomain does not exist.'";
          extraConfig = ''
            add_header Content-Type text/plain;
          '';
        };
      };

      virtualHosts."test.${domain}" = {
        useACMEHost = domain;
        forceSSL = true;
        locations."/" = {
          return = "200 'nginx is working'";
          extraConfig = ''
            add_header Content-Type text/plain;
          '';
        };
      };
    };
  };
}
