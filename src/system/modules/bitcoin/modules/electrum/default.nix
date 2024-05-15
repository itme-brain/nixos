{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.modules.system.bitcoin.electrum;
  home = /var/lib/electrs;

  btc = config.modules.system.bitcoin;

  conf = pkgs.writeText "config.toml" (import ./config { inherit home; });

in
{ options.modules.system.bitcoin.electrum = { enable = mkEnableOption "system.bitcoin.electrum"; };
  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        electrs = prev.electrs.overrideAttrs (old: rec {
          version = "0.10.4";
          src = fetchFromGithub {
            owner = old.owner;
            repo = old.pname;
            rev = "${version}";
            hash = ''
              sha256-0xw2532nmaxx9bjdpnnby03b83wc9zs8bv1wdfgv9q1phccqbkz1
            '';
          };
        });
      })
    ];

    #environment.systemPackages = with pkgs; [
    #  electrs
    #];

    #users = {
    #  users = {
    #    "electrs" = {
    #      inherit home;
    #      description = "electrs system user";
    #      isSystemUser = true;
    #      group = "bitcoin";
    #      createHome = true;
    #    };
    #  };
    #};


    #systemd.services.electrs = {
    #  Unit = {
    #    Description = "Electrs Bitcoin Indexer";
    #    After = [ "network.target" "bitcoind.service" ];
    #    Requires = [ "bitcoind.service" ];
    #  };
    #  Service = {
    #    ExecStartPre = "${pkgs.coreutils}/sleep 10";
    #    ExecStart = "${pkgs.electrs}/bin/electrs --conf=${conf}";

    #    User = "electrs";
    #    Group = "bitcoin";

    #    Type = "simple";
    #    KillMode = "process";
    #    TimeoutSec = 60;
    #    Restart = "always";
    #    RestartSec = 60;
    #  };
    #  Install = {
    #    WantedBy = [ "multi-user.target" ];
    #  };
    #};
  };
}
