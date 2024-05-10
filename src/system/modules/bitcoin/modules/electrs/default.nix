{ lib, pkgs, config, ... }:
#TODO: electrs configuration file

with lib;
  let cfg = config.modules.bitcoin.electrs;
in
{ options.modules.bitcoin.electrs = { enable = mkEnableOption "bitcoin.electrs"; };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      electrs
    ];

    users = {
      users = {
        "electrs" = {
          description = "electrs system user";
          isSystemUser = true;
          group = "bitcoin";
          home = /var/lib/electrs;
          createHome = true;
        };
      };
    };

    systemd.services.electrs = {
      Unit = {
        Description = "Electrs Bitcoin Indexer";
        After = [ "network.target" "bitcoind.service" ];
        Requires = [ "bitcoind.service" ];
      };
      Service = {
        ExecStartPre = "/usr/bin/sleep 10";
        ExecStart = "${pkgs.electrs}/bin/electrs";

        User = "electrs";
        Group = "bitcoin";
        Type = "simple";

        KillMode = "process";
        TimeoutSec = 60;
        Restart = "always";
        RestartSec = 60;
      };
      Install = {
        WantedBy = [ "multi-user.target" ];
      };
    };
  };
}
