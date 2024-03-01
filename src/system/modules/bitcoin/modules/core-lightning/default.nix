{ lib, pkgs, config, ... }:
#TODO: c-lightning config file

with lib;
  let cfg = config.modules.system.bitcoin.core-lightning;

in
{ options.modules.system.bitcoin.core-lightning = { enable = mkEnableOption "system.bitcoin.core-lightning"; };
  config = mkIf cfg.enable {
    imports = [ ./modules ];
    programs.bash.shellAliases = {
      cln = "lightningd";
    };

    environment.systemPackages = with pkgs; [
      clightning
    ];

    users = {
      users = {
        "c-lightning" = {
          description = "core-lightning system user";
          isSystemUser = true;
          group = "bitcoin";
          home = /var/lib/c-lightning;
          createHome = true;
        };
      };
    };

    systemd.services.lightningd = {
      Unit = {
        Description = "Core Lightning daemon";
        Requires = [ "bitcoind.service" ];
        After = [ "bitcoind.service" "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        ExecStartPre =
        let
          lightningConf = ''
          ''; #put lightning conf here
        in
          "${pkgs.writeShellScript "prepare-clightning-config" ''
            mkdir -p /var/lib/c-lightning/.lightning
            chown -R c-lightning:bitcoin /var/lib/c-lightning
            echo "${lightningConf}" > /var/lib/c-lightning/.lightning/config
            chmod 600 /var/lib/c-lightning/.lightning/config
          ''}";

        ExecStart = "${pkgs.clightning}/bin/lightningd --conf=/var/lib/c-lightning/.lightning/config";

        RuntimeDirectory = "lightningd";

        User = "c-lightning";
        Group = "bitcoin";

        Type = "forking";
        PIDFile = "/run/lightningd/lightningd.pid";
        Restart = "on-failute";

        PrivateTmp = true;
        ProtectSystem = "full";
        NoNewPrivileges = true;
        PrivateDevies = true;
        MemoryDenyWriteAccess = false;
      };
      Install = {
        WantedBy = [ "multi-user.target" ];
      };
    };
  };
}
