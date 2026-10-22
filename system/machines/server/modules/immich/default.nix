{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.immich;
  nginx = config.modules.system.nginx;
  domain = "ramos.codes";
  port = 2283;
  # Temporary runtime override: restore pkgs.unstable.immich once its shipped
  # Node runtime and shared dependencies are verified patched; see nodejs-security.nix.
  immichRuntime = pkgs.symlinkJoin {
    name = "immich-${pkgs.unstable.immich.version}-node-${pkgs.nodejsSecurity.version}";
    paths = [ pkgs.unstable.immich ];
    postBuild = ''
      for program in server immich-admin; do
        cp --remove-destination "${pkgs.unstable.immich}/bin/$program" "$out/bin/$program"
        chmod u+w "$out/bin/$program"
        substituteInPlace "$out/bin/$program" \
          --replace-fail '${lib.getExe pkgs.unstable.nodejs}' '${lib.getExe pkgs.nodejsSecurity}'
      done
    '';
    inherit (pkgs.unstable.immich) meta;
    passthru = pkgs.unstable.immich.passthru;
  };
  privateAccessRules = concatMapStringsSep "\n" (cidr: "allow ${cidr};") nginx.privateAllowCidrs + "\ndeny all;";

in
{
  options.modules.system.immich = {
    enable = mkEnableOption "Immich Photo Server";
  };

  config = mkIf cfg.enable {
    # Bind mount from /data
    systemd.tmpfiles.rules = [
      "d /data/immich 0750 immich immich -"
      "d /data/postgresql 0750 postgres postgres -"
    ];

    fileSystems."/var/lib/immich" = {
      device = "/data/immich";
      fsType = "none";
      options = [ "bind" ];
    };

    fileSystems."/var/lib/postgresql" = {
      device = "/data/postgresql";
      fsType = "none";
      options = [ "bind" ];
    };

    # Authentication is managed in Immich's persistent database through its
    # native OIDC settings: Authentik issuer /application/o/immich/, automatic
    # OAuth login, and password login disabled. The Authentik Immich application
    # requires membership in the manually maintained "AI users" whitelist.
    # Keep settings unset here so existing UI-managed application settings remain
    # editable; the client secret belongs in the databases, never the Nix store.
    services.immich = {
      enable = true;
      # Immich 2.x in 26.05 is end-of-life; use the supported 3.x release.
      package = immichRuntime;
      port = port;
      host = "127.0.0.1";
      mediaLocation = "/var/lib/immich";
      machine-learning.enable = false;
    };

    # Use the corrected host store instead of Node's embedded root bundle.
    systemd.services.immich-server.environment = {
      NODE_OPTIONS = "--use-openssl-ca";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };

    systemd.services.immich-dump = {
      description = "Consistent Immich database snapshot for encrypted backups";
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
      serviceConfig = { Type = "oneshot"; UMask = "0077"; };
      script = ''
        set -euo pipefail
        temp=$(mktemp /var/lib/backup/immich.dump.XXXXXX)
        globals=$(mktemp /var/lib/backup/postgresql-globals.sql.XXXXXX)
        trap 'rm -f "$temp" "$globals"' EXIT
        ${pkgs.util-linux}/bin/runuser -u postgres -- \
          ${config.services.postgresql.package}/bin/pg_dump --format=custom immich > "$temp"
        ${config.services.postgresql.package}/bin/pg_restore --file=/dev/null "$temp"
        ${pkgs.util-linux}/bin/runuser -u postgres -- \
          ${config.services.postgresql.package}/bin/pg_dumpall --globals-only > "$globals"
        mv "$temp" /var/lib/backup/immich.dump
        mv "$globals" /var/lib/backup/postgresql-globals.sql
      '';
    };
    systemd.services.backup = {
      requires = [ "immich-dump.service" ];
      after = [ "immich-dump.service" ];
    };
    modules.system.backup = {
      paths = [ "/var/lib/immich" ];
      # Use the fresh logical dump, not Immich's accumulated internal dumps.
      exclude = [ "var/lib/immich/backups" ];
    };

    services.nginx.virtualHosts."photos.${domain}" = mkIf nginx.enable {
      useACMEHost = domain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true;
        extraConfig = privateAccessRules;
      };
    };
  };
}
