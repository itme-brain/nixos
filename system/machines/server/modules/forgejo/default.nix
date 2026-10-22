{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.forgejo;
  nginx = config.modules.system.nginx;
  domain = "ramos.codes";
  socketPath = "/run/forgejo/forgejo.sock";
  sshPort = 2222;
  sshKeyExchanges = concatStringsSep "," [
    "mlkem768x25519-sha256"
    "curve25519-sha256"
    "ecdh-sha2-nistp256"
    "ecdh-sha2-nistp384"
    "ecdh-sha2-nistp521"
    "diffie-hellman-group14-sha256"
  ];
  sshMacs = concatStringsSep "," [
    "hmac-sha2-256-etm@openssh.com"
    "hmac-sha2-256"
  ];

in
{
  options.modules.system.forgejo = {
    enable = mkEnableOption "Forgejo Server";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ sshPort ];

    users.groups.git = {};
    users.users.git = {
      isSystemUser = true;
      group = "git";
      home = "/var/lib/forgejo";
      shell = "${pkgs.bash}/bin/bash";
    };

    users.users.nginx = mkIf nginx.enable {
      extraGroups = [ "git" ];
    };

    # Bind mount from /data
    fileSystems."/var/lib/forgejo" = {
      device = "/data/forgejo";
      fsType = "none";
      options = [ "bind" ];
    };

    systemd.tmpfiles.rules = [
      "d /data/forgejo 0750 git git -"
      "d /data/forgejo/.ssh 0700 git git -"
      "d /data/forgejo/custom 0750 git git -"
      "d /data/forgejo/data 0750 git git -"
    ];

    services.forgejo = {
      enable = true;
      user = "git";
      group = "git";
      stateDir = "/var/lib/forgejo";

      settings = {
        DEFAULT = {
          APP_NAME = "Git Server";
          APP_SLOGAN = "";
        };

        service.REQUIRE_SIGNIN_VIEW = false;
        server = {
          DOMAIN = "git.${domain}";
          ROOT_URL = "https://git.${domain}/";
          PROTOCOL = "http+unix";
          HTTP_ADDR = socketPath;
          SSH_DOMAIN = "git.${domain}";
          SSH_PORT = sshPort;
          SSH_LISTEN_HOST = "0.0.0.0";
          SSH_LISTEN_PORT = sshPort;
          START_SSH_SERVER = true;
          SSH_SERVER_KEY_EXCHANGES = sshKeyExchanges;
          SSH_SERVER_MACS = sshMacs;
          MINIMUM_KEY_SIZE_CHECK = true;
          SSH_ALLOW_UNEXPECTED_AUTHORIZED_KEYS = false;
          LANDING_PAGE = "explore";
          LFS_MAX_FILE_SIZE = 0;
        };

        "repository.upload" = {
          FILE_MAX_SIZE = 0;
        };

        service = {
          # Authentik approves users through its manually maintained whitelist.
          # Its OIDC source and client secret are persisted in Forgejo's database.
          ENABLE_INTERNAL_SIGNIN = false;
          ENABLE_BASIC_AUTHENTICATION = false;
          DISABLE_REGISTRATION = true;
          ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
          SHOW_REGISTRATION_BUTTON = false;
          REGISTER_MANUAL_CONFIRM = false;
          REQUIRE_EXTERNAL_REGISTRATION_PASSWORD = false;
          DEFAULT_ALLOW_CREATE_ORGANIZATION = false;
        };

        oauth2_client = {
          # Provision accounts only after the Authentik application permits login.
          ENABLE_AUTO_REGISTRATION = true;
          REGISTER_EMAIL_CONFIRM = false;
          # Existing accounts require an explicit identity link, never a name match.
          ACCOUNT_LINKING = "disabled";
        };

        openid = {
          # Legacy OpenID is separate from the configured OIDC source.
          ENABLE_OPENID_SIGNIN = false;
          ENABLE_OPENID_SIGNUP = false;
        };

        admin = {
          DISABLE_REGULAR_ORG_CREATION = true;
        };

      };

      database = {
        type = "sqlite3";
        path = "/var/lib/forgejo/data/forgejo.db";
      };
    };

    modules.system.backup.paths = [
      "/var/lib/forgejo"
    ];
    modules.system.backup.exclude = [
      "var/lib/forgejo/data/forgejo.db*"
      "var/lib/forgejo/log"
    ];
    systemd.services.forgejo-dump = {
      description = "Consistent Forgejo SQLite snapshot for encrypted backups";
      requires = [ "forgejo.service" ];
      after = [ "forgejo.service" ];
      serviceConfig = { Type = "oneshot"; UMask = "0077"; };
      script = ''
        set -euo pipefail
        temp=$(mktemp /var/lib/backup/forgejo.db.XXXXXX)
        trap 'rm -f "$temp"' EXIT
        ${pkgs.sqlite}/bin/sqlite3 ${lib.escapeShellArg config.services.forgejo.database.path} ".backup '$temp'"
        # Produce a self-contained snapshot without WAL/shm sidecar files.
        ${pkgs.sqlite}/bin/sqlite3 "$temp" 'PRAGMA journal_mode=DELETE;' >/dev/null
        test "$(${pkgs.sqlite}/bin/sqlite3 "$temp" 'PRAGMA integrity_check;')" = ok
        mv "$temp" /var/lib/backup/forgejo.db
      '';
    };
    systemd.services.backup = {
      requires = [ "forgejo-dump.service" ];
      after = [ "forgejo-dump.service" ];
    };

    services.nginx.virtualHosts."git.${domain}" = mkIf nginx.enable {
      useACMEHost = domain;
      forceSSL = true;
      extraConfig = ''
        client_max_body_size 0;
        add_header Strict-Transport-Security "max-age=31536000" always;
        add_header X-Content-Type-Options "nosniff" always;
      '';
      locations."/" = {
        proxyPass = "http://unix:${socketPath}";
      };
    };
  };
}
