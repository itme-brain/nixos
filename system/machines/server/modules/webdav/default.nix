{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.webdav;
  domain = "ramos.codes";

in
{
  options.modules.system.webdav = {
    enable = mkEnableOption "WebDAV server for phone backups";

    directory = mkOption {
      type = types.path;
      default = "/var/lib/seedvault";
      description = "Directory to store backups";
    };
  };

  config = mkIf cfg.enable {
    # Create backup directory
    systemd.tmpfiles.rules = [
      "d ${cfg.directory} 0750 webdav webdav -"
    ];

    services.webdav = {
      enable = true;
      # Credentials in /var/lib/webdav/env:
      # WEBDAV_USERNAME=seedvault
      # WEBDAV_PASSWORD=your-secure-password
      environmentFile = "/var/lib/webdav/env";
      settings = {
        address = "127.0.0.1";
        port = 8090;
        directory = cfg.directory;
        behindProxy = true;
        permissions = "CRUD";  # Create, Read, Update, Delete
        users = [
          {
            username = "{env}WEBDAV_USERNAME";
            password = "{env}WEBDAV_PASSWORD";
          }
        ];
      };
    };

    services.nginx.virtualHosts."backup.${domain}" = {
      useACMEHost = domain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8090";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;

          # WebDAV needs these
          proxy_pass_request_headers on;
          proxy_set_header Destination $http_destination;

          # Large file uploads for backups
          client_max_body_size 0;
          proxy_request_buffering off;
        '';
      };
    };
  };
}
