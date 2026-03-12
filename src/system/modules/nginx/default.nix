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
    networking.firewall.allowedTCPPorts = [ 80 /* 443 */ ];

    # security.acme = {
    #   acceptTerms = true;
    #   defaults.email = config.user.email;
    #
    #   certs."${domain}" = {
    #     domain = "*.${domain}";
    #     dnsProvider = "namecheap";
    #     environmentFile = "/var/lib/acme/namecheap.env";
    #     group = "nginx";
    #   };
    # };

    services.nginx = {
      enable = true;
      # recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      virtualHosts."test.${domain}" = {
        # useACMEHost = domain;
        # forceSSL = true;
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
