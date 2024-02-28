{ lib, pkgs, config, ... }:

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
        };
      };
    };

    systemd.services.electrs = {
      Unit = {
        after = [ "network.target" "bitcoind.service" ];
        wantedBy = [ "multi-user.target" ];
      };
      Service = {
        ExecStart = "${pkgs.electrs}/bin/electrs --conf=...";
        Restart = "always";
        User = "electrs";
        Group = "bitcoin";
      };
    };
  };
}
