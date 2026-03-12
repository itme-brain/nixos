{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.forgejo;
  nginx = config.modules.system.nginx;
  domain = "ramos.codes";
  socketPath = "/run/forgejo/forgejo.sock";

in
{
  options.modules.system.forgejo = {
    enable = mkEnableOption "Forgejo Server";
  };

  config = mkIf cfg.enable {
    users.groups.git = {};
    users.users.git = {
      isSystemUser = true;
      group = "git";
      home = "/var/lib/forgejo";
      shell = "${pkgs.git}/bin/git-shell";
    };

    users.users.nginx = mkIf nginx.enable {
      extraGroups = [ "git" ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/forgejo 0750 git git -"
      "d /var/lib/forgejo/custom 0750 git git -"
      "d /var/lib/forgejo/data 0750 git git -"
    ];

    services.forgejo = {
      enable = true;
      user = "git";
      group = "git";
      stateDir = "/var/lib/forgejo";

      settings.server = {
        DOMAIN = "git.${domain}";
        ROOT_URL = "https://git.${domain}/";
        PROTOCOL = "http+unix";
        HTTP_ADDR = socketPath;
        SSH_DOMAIN = "git.${domain}";
        SSH_PORT = 22;
        START_SSH_SERVER = false;
      };

      database = {
        type = "sqlite3";
        path = "/var/lib/forgejo/data/forgejo.db";
      };
    };

    services.nginx.virtualHosts."git.${domain}" = mkIf nginx.enable {
      useACMEHost = domain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://unix:${socketPath}";
      };
    };
  };
}
