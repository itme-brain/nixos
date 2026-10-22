{ config, lib, pkgs, ... }:
let
  # Official release, shared by the HTTP service and background worker.
  image = "ghcr.io/goauthentik/server@sha256:e7226ae116dac5aa0a5643803e735b010038f492c401e08e16b3bf1ac54c090c"; # 2026.8.4
  credentials = config.sops.secrets."authentik.env".path;
  common = {
    inherit image;
    environmentFiles = [ credentials ];
    environment = {
      AUTHENTIK_POSTGRESQL__HOST = "127.0.0.1";
      AUTHENTIK_POSTGRESQL__PORT = "55432";
      AUTHENTIK_POSTGRESQL__NAME = "authentik";
      AUTHENTIK_POSTGRESQL__USER = "authentik";
      AUTHENTIK_LISTEN__HTTP = "127.0.0.1:9000";
      AUTHENTIK_LISTEN__HTTPS = "127.0.0.1:9443";
      AUTHENTIK_ERROR_REPORTING__ENABLED = "false";
      AUTHENTIK_DISABLE_UPDATE_CHECK = "true";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
      REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
      AWS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    };
    volumes = [
      "/var/lib/authentik/data:/data"
      "${config.system.build.containerCA}:/etc/ssl/certs:ro"
      "${config.system.build.containerCA}/ca-certificates.crt:/ak-root/.venv/lib/python3.14/site-packages/certifi/cacert.pem:ro"
      "${config.system.build.containerCA}/ca-certificates.crt:/ak-root/.venv/lib/python3.14/site-packages/botocore/cacert.pem:ro"
      "${config.system.build.containerCA}/ca-certificates.crt:/usr/local/lib/python3.14/site-packages/pip/_vendor/certifi/cacert.pem:ro"
    ];
    extraOptions = [ "--network=host" "--shm-size=512m" ];
    dependsOn = [ "authentik-postgresql" ];
  };
  securityHeaders = ''
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "same-origin" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
  '';
  browserAuth = ''
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-Port 443;
    proxy_set_header Forwarded "";
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Real-IP $remote_addr;
    auth_request /_ai_auth;
    error_page 401 = @ai_signin;
    auth_request_set $auth_cookie $upstream_http_set_cookie;
    add_header Set-Cookie $auth_cookie always;
  '' + securityHeaders;
in {
  options.modules.system.authentik.protectAI = lib.mkEnableOption "shared sign-in for AI browser applications";

  config = {
  systemd.tmpfiles.rules = [
    "d /var/lib/authentik 0750 root root -"
    "d /var/lib/authentik/data 0750 1000 1000 -"
    # The image owns its data directory; preserve that ownership on rebuilds.
    "d /var/lib/authentik/postgresql 0700 - - -"
    "d /var/lib/authentik/backups 0700 root root -"
  ];

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      authentik-postgresql = {
        image = "docker.io/library/postgres@sha256:721873c34ceb9f8d8fc265984940dc982404c105f19ad51be9fdc5970a6080ea";
        environmentFiles = [ credentials ];
        environment = { POSTGRES_DB = "authentik"; POSTGRES_USER = "authentik"; };
        volumes = [
          "/var/lib/authentik/postgresql:/var/lib/postgresql/data"
          "${config.system.build.containerCA}:/etc/ssl/certs:ro"
        ];
        extraOptions = [ "--network=host" ];
        cmd = [ "postgres" "-p" "55432" "-c" "listen_addresses=127.0.0.1" ];
      };
      authentik-server = common // {
        cmd = [ "server" ];
        environment = common.environment // { AUTHENTIK_LISTEN__METRICS = "127.0.0.1:9300"; };
      };
      authentik-worker = common // {
        cmd = [ "worker" ];
        environment = common.environment // {
          AUTHENTIK_LISTEN__HTTP = "127.0.0.1:9001";
          AUTHENTIK_LISTEN__HTTPS = "127.0.0.1:9444";
          AUTHENTIK_LISTEN__METRICS = "127.0.0.1:9301";
        };
      };
    };
  };

  systemd.services.authentik-dump = {
    description = "Consistent Authentik database snapshot for encrypted backups";
    requires = [ "podman-authentik-postgresql.service" ];
    after = [ "podman-authentik-postgresql.service" ];
    script = ''
      set -euo pipefail
      temp=$(mktemp /var/lib/authentik/backups/authentik.dump.XXXXXX)
      trap 'rm -f "$temp"' EXIT
      ${pkgs.podman}/bin/podman exec authentik-postgresql \
        pg_dump --port 55432 --username authentik --format custom authentik > "$temp"
      ${pkgs.podman}/bin/podman exec -i authentik-postgresql \
        pg_restore --file=/dev/null < "$temp"
      mv "$temp" /var/lib/authentik/backups/authentik.dump
    '';
    serviceConfig = {
      Type = "oneshot";
      UMask = "0077";
    };
  };
  systemd.services.backup = {
    requires = [ "authentik-dump.service" ];
    after = [ "authentik-dump.service" ];
  };
  modules.system.backup.paths = [
    "/var/lib/authentik/backups"
    "/var/lib/authentik/data"
  ];

  services.nginx.virtualHosts."auth.ramos.codes" = {
    useACMEHost = "ramos.codes";
    forceSSL = true;
    extraConfig = ''
      add_header Strict-Transport-Security "max-age=31536000" always;
    '';
    locations."^~ /branding/" = {
      alias = "${./branding}/";
    };
    locations."/" = {
      proxyPass = "http://127.0.0.1:9000";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port 443;
        proxy_set_header Forwarded "";
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 300s;
      '';
    };
  };

  services.nginx.virtualHosts."ai.ramos.codes".extraConfig = lib.mkIf config.modules.system.authentik.protectAI securityHeaders;
  services.nginx.virtualHosts."ai.ramos.codes".locations = lib.mkIf config.modules.system.authentik.protectAI {
    "/".extraConfig = browserAuth;
    "= /_ai_auth" = {
      proxyPass = "http://127.0.0.1:9000/outpost.goauthentik.io/auth/nginx";
      extraConfig = ''
        internal;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Host $host;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
        proxy_set_header Authorization "";
        proxy_set_header X-Original-URL https://ai.ramos.codes$request_uri;
        proxy_set_header X-Original-URI $request_uri;
        proxy_set_header X-Forwarded-Proto https;
      '';
    };
    "@ai_signin".extraConfig = ''
      return 302 /outpost.goauthentik.io/start?rd=https://ai.ramos.codes$request_uri;
    '';
    "^~ /outpost.goauthentik.io/" = {
      proxyPass = "http://127.0.0.1:9000/outpost.goauthentik.io/";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Original-URL https://ai.ramos.codes$request_uri;
        proxy_set_header X-Original-URI $request_uri;
        proxy_set_header X-Forwarded-Proto https;
      '';
    };
    # Native clients retain Bearer-key authentication at the rigby gateway.
    "^~ /v1/" = {
      proxyPass = "http://192.168.0.23:9331";
      proxyWebsockets = true;
      extraConfig = "proxy_read_timeout 3600s; proxy_buffering off;";
    };
    "^~ /oauth/" = {
      proxyPass = "http://192.168.0.23:9331";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Real-IP $remote_addr;
      '';
    };
    "= /health".proxyPass = "http://192.168.0.23:9331";
    "= /systemone".return = "302 /systemone/";
    "^~ /systemone/" = {
      proxyPass = "http://192.168.0.23:9331";
      proxyWebsockets = true;
      extraConfig = browserAuth + ''
        client_max_body_size 32m;
        proxy_read_timeout 180s;
      '';
    };
  };
  };
}
