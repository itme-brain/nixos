{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.modules.system.bitcoin.electrum;
  home = "/var/lib/electrs";

  btc = config.modules.system.bitcoin;

  conf = pkgs.writeText "config.toml" (import ./config);

in
{ options.modules.system.bitcoin.electrum = { enable = mkEnableOption "system.bitcoin.electrum"; };
  config = mkIf cfg.enable {
    #nixpkgs.overlays = [
    #  (final: prev: {
    #    electrs = prev.electrs.overrideAttrs (old: rec {
    #      version = "0.10.4";
    #      src = fetchFromGithub {
    #        rev = "${version}";
    #        hash = ''
    #          sha256-0xw2532nmaxx9bjdpnnby03b83wc9zs8bv1wdfgv9q1phccqbkz1
    #        '';
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
          description = "electrs system user";
          isSystemUser = true;
          group = "bitcoin";
          createHome = true;
        };
      };
    };


    systemd.services.electrs = {
      description = "Electrs Bitcoin Indexer";

      preStart = "${pkgs.coreutils}/sleep 5";
      script = "${pkgs.electrs}/bin/electrs";
      scriptArgs = "--config=${conf}";

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
