{ lib, pkgs, config, ... }:

with lib;
  let cfg = config.modules.system.bitcoin.core-lightning;

in
{ options.modules.system.bitcoin.core-lightning = { enable = mkEnableOption "system.bitcoin.core-lightning"; };
  config = mkIf cfg.enable {
    imports = [  ./modules ];
    programs.bash.shellAliases = {
      cln = "lightningd";
    };

    home.packages = with pkgs; [
      clightning
    ];

    users = {
      users = {
        "clightning" = {
          description = "clightning system user";
          isSystemUser = true;
          group = "bitcoin";
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
        ExecStartPre = "/usr/bin/sleep 10";
        ExecStart = "${pkgs.clightning}/bin/lightningd --conf=/var/lib/clightning/.lightning/config";

        RuntimeDirectory = "lightningd";

        User = "clightning";
        Group = "bitcoin";

        Type = "forking";
        PIDFile = "/run/lightningd/lightningd.pid";
        Restart = "on-failute";

        PrivateTmp = true;
        ProtectSystem = "full";
        NoNewPrivileges = true;
        PrivateDevies = true;
      };
      Install = {
        WantedBy = [ "multi-user.target" ];
      };
    };
  };
}
