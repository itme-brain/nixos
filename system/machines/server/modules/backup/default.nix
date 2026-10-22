{ pkgs, lib, config, inputs, ... }:

with lib;
let
  cfg = config.modules.system.backup;

  recipientArgs = concatMapStrings (r: "-r '${lib.strings.trim r}' ") cfg.recipients;

  # Convert absolute paths to relative for tar, preserving structure
  # e.g., /var/lib/forgejo -> var/lib/forgejo
  tarPaths = map (p: removePrefix "/" p) cfg.paths;
  excludeArgs = concatMapStrings (e: "--exclude='${e}' ") cfg.exclude;
  backupSpec = pkgs.writeText "backup-spec.json" (builtins.toJSON {
    version = 1;
    paths = cfg.paths;
    exclude = cfg.exclude;
    retention = cfg.keepLast;
    deployedConfiguration = inputs.self.outPath;
    databaseSnapshots = {
      immich = "var/lib/backup/immich.dump";
      postgresqlRoles = "var/lib/backup/postgresql-globals.sql";
      forgejo = "var/lib/backup/forgejo.db";
      authentik = "var/lib/authentik/backups/authentik.dump";
    };
  });

  backupScript = pkgs.writeShellScript "backup" ''
    set -euo pipefail

    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    BACKUP_NAME="backup-$TIMESTAMP.tar.gz.age"
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    echo "Starting backup: $BACKUP_NAME"
    echo "Paths: ${concatStringsSep " " cfg.paths}"

    ${pkgs.jq}/bin/jq \
      --arg createdAt "$(date --utc +%FT%TZ)" \
      --arg system "$(readlink -f /run/current-system)" \
      '. + {createdAt: $createdAt, system: $system}' \
      ${backupSpec} > /var/lib/backup/manifest.json

    export PATH="${pkgs.gzip}/bin:${pkgs.age-plugin-yubikey}/bin:$PATH"
    ${pkgs.gnutar}/bin/tar --acls --xattrs --numeric-owner -C / ${excludeArgs}-czf - ${concatStringsSep " " tarPaths} | \
      ${pkgs.age}/bin/age ${recipientArgs} -o "$TEMP_DIR/$BACKUP_NAME"

    ${pkgs.rclone}/bin/rclone --config /root/.config/rclone/rclone.conf copy "$TEMP_DIR/$BACKUP_NAME" "${cfg.destination}"
    # Verify the uploaded archive's hash before pruning the previous snapshot.
    ${pkgs.rclone}/bin/rclone --config /root/.config/rclone/rclone.conf check \
      --one-way --include "$BACKUP_NAME" "$TEMP_DIR" "${cfg.destination}"

    # Prune only backup archives managed by this service.
    ${pkgs.rclone}/bin/rclone --config /root/.config/rclone/rclone.conf lsf \
      --files-only --include 'backup-*.tar.gz.age' "${cfg.destination}" | \
      sort -r | \
      tail -n +$((${toString cfg.keepLast} + 1)) | \
      while read -r old; do
        ${pkgs.rclone}/bin/rclone --config /root/.config/rclone/rclone.conf deletefile \
          ${optionalString cfg.permanentlyDeletePruned "--drive-use-trash=false"} "${cfg.destination}/$old"
      done

    echo "Backup complete"
  '';

in
{
  options.modules.system.backup = {
    enable = mkEnableOption "Encrypted backups";

    paths = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Absolute paths to include in backup (structure preserved)";
    };

    exclude = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Patterns to exclude (passed to tar --exclude)";
    };

    recipients = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Age public keys for encryption";
    };

    destination = mkOption {
      type = types.str;
      default = "";
      description = "Rclone destination";
    };

    schedule = mkOption {
      type = types.str;
      default = "daily";
      description = "Systemd calendar expression";
    };

    keepLast = mkOption {
      type = types.int;
      default = 3;
      description = "Number of backups to keep";
    };

    permanentlyDeletePruned = mkOption {
      type = types.bool;
      default = false;
      description = "Permanently delete pruned Google Drive backups instead of moving them to trash";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.rclone ];
    systemd.tmpfiles.rules = [ "d /var/lib/backup 0700 root root -" ];
    modules.system.backup.paths = [
      "/var/lib/backup"
      "/home/${config.user.name}/nixos"
      # Include the deployed source with resolved submodules as well as pending edits.
      inputs.self.outPath
      "/var/lib/sops-nix/key.txt"
      "/etc/ssh"
      "/var/lib/acme"
    ];
    modules.system.backup.exclude = [
      # Only current application state; omit checkout caches and Git reflog history.
      "home/${config.user.name}/nixos/.direnv"
      "home/${config.user.name}/nixos/.git"
      "var/lib/backup/forgejo.db-*"
    ];

    systemd.services.backup = {
      description = "Encrypted backup";
      serviceConfig = {
        Type = "oneshot";
        UMask = "0077";
        ExecStart = backupScript;
      };
    };

    systemd.timers.backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
      };
    };
  };
}
