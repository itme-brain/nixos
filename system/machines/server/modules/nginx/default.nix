{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.nginx;
  domain = "ramos.codes";
  privateAccessRules = concatMapStringsSep "\n" (cidr: "allow ${cidr};") cfg.privateAllowCidrs + "\ndeny all;";

in
{
  options.modules.system.nginx = {
    enable = mkEnableOption "Nginx Reverse Proxy";

    privateAllowCidrs = mkOption {
      type = types.listOf types.str;
      default = [
        "192.168.0.0/24"
        "10.8.0.0/24"
      ];
      description = ''
        CIDR ranges allowed to access private vhosts (LAN + WireGuard).
      '';
    };

  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    systemd.services.nginx.serviceConfig.LimitNOFILE = 65536;

    environment.etc."fail2ban/filter.d/nginx-404.conf".text = ''
      [Definition]
      failregex = ^<HOST> - .+ "(GET|POST|HEAD|PUT|DELETE|PATCH) .+ HTTP/[0-9.]+" 404
      ignoreregex =
    '';

    environment.etc."fail2ban/filter.d/nginx-401.conf".text = ''
      [Definition]
      failregex = ^<HOST> - .+ "(GET|POST|HEAD|PUT|DELETE|PATCH) .+ HTTP/[0-9.]+" 401
      ignoreregex =
    '';

    services.fail2ban.jails.nginx-404 = ''
      enabled   = true
      filter    = nginx-404
      logpath   = /var/log/nginx/access.log
      maxretry  = 10
      findtime  = 10m
      bantime   = 24h
    '';

    services.fail2ban.jails.nginx-401 = ''
      enabled   = true
      filter    = nginx-401
      logpath   = /var/log/nginx/access.log
      maxretry  = 5
      findtime  = 10m
      bantime   = 24h
    '';

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

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      eventsConfig = "worker_connections 4096;";

      # CORS origin allowlist for MCP servers
      commonHttpConfig = ''
        map $http_origin $mcp_cors_origin {
          default "";
          "https://ai.${domain}" "https://ai.${domain}";
        }
      '';

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

      virtualHosts."wg.${domain}" = {
        useACMEHost = domain;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.modules.system.wstunnel.listenPort}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
          '';
        };
      };

      virtualHosts."ai.${domain}" = let
        apiKeyAuth = ''
          set $api_key "";
          if ($http_authorization ~* "^Bearer (.+)$") {
            set $api_key $1;
          }
          if ($api_key = "") {
            return 401 '{"error": "Missing Authorization header"}';
          }
          include ${config.sops.templates."nginx-ai-auth.conf".path};
        '';
      in {
        useACMEHost = domain;
        forceSSL = true;

        # Web UI + llama.cpp API (browser, /v1/* calls from the UI)
        # Auth handled by llama.cpp itself (--api-key flag)
        locations."/" = {
          proxyPass = "http://192.168.0.23:8000";
          proxyWebsockets = true;
        };

        # Llama Stack API (opencode, programmatic clients)
        # Clients use baseURL: https://ai.ramos.codes/stack/v1
        locations."/stack/v1/" = {
          proxyPass = "http://192.168.0.23:8321/v1/";
          proxyWebsockets = true;
          extraConfig = apiKeyAuth + ''
            proxy_read_timeout 300s;
            proxy_send_timeout 300s;
          '';
        };

      };

      virtualHosts."mcp.${domain}" = {
        useACMEHost = domain;
        forceSSL = true;

        locations."/web_search/" = {
          proxyPass = "http://192.168.0.23:8002/";
          proxyWebsockets = true;
          extraConfig = ''
            include ${config.sops.templates."nginx-mcp-auth.conf".path};

            # CORS — $mcp_cors_origin is set by the http-level map
            # and is empty for disallowed origins
            if ($request_method = OPTIONS) {
              add_header Access-Control-Allow-Origin $mcp_cors_origin always;
              add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
              add_header Access-Control-Allow-Headers "Content-Type, Authorization, X-API-Key" always;
              add_header Access-Control-Allow-Credentials "true" always;
              add_header Access-Control-Max-Age 86400 always;
              return 204;
            }

            add_header Access-Control-Allow-Origin $mcp_cors_origin always;
            add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Content-Type, Authorization, X-API-Key" always;
            add_header Access-Control-Allow-Credentials "true" always;

            proxy_read_timeout 300s;
            proxy_send_timeout 300s;
          '';
        };
      };

      virtualHosts."comfy.${domain}" = {
        useACMEHost = domain;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://192.168.0.23:8188";
          proxyWebsockets = true;
          extraConfig = privateAccessRules;
        };
      };
    };
  };
}
