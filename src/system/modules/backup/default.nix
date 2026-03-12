{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.backup;

  recipientArgs = concatMapStrings (r: "-r '${r}' ") cfg.recipients;

  # Convert absolute paths to relative for tar, preserving structure
  # e.g., /var/lib/forgejo -> var/lib/forgejo
  tarPaths = map (p: removePrefix "/" p) cfg.paths;

  backupScript = pkgs.writeShellScript "backup" ''
    set -euo pipefail

    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    BACKUP_NAME="backup-$TIMESTAMP.tar.age"
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    echo "Starting backup: $BACKUP_NAME"
    echo "Paths: ${concatStringsSep " " cfg.paths}"

    ${pkgs.gnutar}/bin/tar -C / -cf - ${concatStringsSep " " tarPaths} | \
      ${pkgs.age}/bin/age ${recipientArgs} -o "$TEMP_DIR/$BACKUP_NAME"

    ${pkgs.rclone}/bin/rclone copy "$TEMP_DIR/$BACKUP_NAME" "${cfg.destination}"

    # Prune old backups
    ${pkgs.rclone}/bin/rclone lsf "${cfg.destination}" | \
      sort -r | \
      tail -n +$((${toString cfg.keepLast} + 1)) | \
      while read -r old; do
        ${pkgs.rclone}/bin/rclone delete "${cfg.destination}/$old"
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
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.rclone ];

    systemd.services.backup = {
      description = "Encrypted backup";
      serviceConfig = {
        Type = "oneshot";
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
