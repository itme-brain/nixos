{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.modules.system.bitcoin.electrum;
  home = "/var/lib/electrs";

  btc = config.modules.system.bitcoin;

  electrsConfig = pkgs.writeTextFile {
    name = "config.toml";
    text = builtins.readFile ./config/config.toml;
  };

in
{ options.modules.system.bitcoin.electrum = { enable = mkEnableOption "Electrs Server"; };
  config = mkIf (cfg.enable && btc.enable) {
    #nixpkgs.overlays = [
    #  (final: prev: {
    #    electrs = prev.electrs.overrideAttrs (old: rec {
    #      version = "0.10.4";
    #      src = pkgs.fetchFromGitHub {
    #        owner = "romanz";

    #        rev = "${version}";
    #        hash = "sha256-4c+FGYM34LSfazzshfRPjA+0BvDL2tvkSr2rasUognc=";
    #      };
    #    });
    #  })
    #];

    environment.systemPackages = with pkgs; [
      electrs
    ];

    users = {
      users = {
        "electrs" = {
          inherit home;
          description = "Electrs system user";
          isSystemUser = true;
          group = "bitcoin";
          createHome = true;
        };
      };
      groups = {
        "bitcoin" = {
          members = mkAfter [
            "electrs"
          ];
        };
      };
    };


    systemd.services.electrs = {
      description = "Electrs Bitcoin Indexer";

      script = "${pkgs.electrs}/bin/electrs";
      scriptArgs = "--conf=${electrsConfig}";

      after = [
        "bitcoind-btc.service"
      ];

      serviceConfig = {

        User = "electrs";
        Group = "bitcoin";

        Type = "simple";
        KillMode = "process";
        TimeoutSec = 60;
        Restart = "always";
        RestartSec = 60;
      };
      requisite = [
        "bitcoind-btc.service"
        "network.target"
      ];
    };
  };
}
