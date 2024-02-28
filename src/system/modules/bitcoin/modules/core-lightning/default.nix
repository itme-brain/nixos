{ lib, pkgs, config, ... }:

with lib;
  let cfg = config.modules.bitcoin.core-lightning;

in
{ options.modules.bitcoin.core-lightning = { enable = mkEnableOption "bitcoin.core-lightning"; };
  config = mkIf cfg.enable {
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

    systemd.services.clightning = {
      Unit = {
        after = [ "network.target" "bitcoind.service" ];
        wantedBy = [ "multi-user.target" ];
      };
      Service = {
        ExecStart = "${pkgs.clightning}/bin/lightningd --conf=...";
        Restart = "always";
        User = "clightning";
        Group = "bitcoin";
      };
    };
  };
}
