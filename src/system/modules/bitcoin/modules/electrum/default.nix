{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.modules.system.bitcoin.electrum;
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
    #      version = "0.10.6";
    #      src = pkgs.fetchFromGitHub {
    #        owner = "romanz";
    #        repo = "electrs";
    #        rev = "v${version}";
    #        hash = "sha256-yp9fKD7zH9Ne2+WQUupaxvUx39RWE8RdY4U6lHuDGSc=";
    #      };
    #      cargoDeps = old.cargoDeps.overrideAttrs (lib.const {
    #        name = "electrs-vendor.tar.gz";
    #        inherit src;
    #        outputHash = "sha256-qQKAQHOAeYWQ5YVtx12hIAjNA7Aj1MW1m+WimlBWPv0=";
    #      });
    #    });
    #  })
    #];

    environment.systemPackages = with pkgs; [
      electrs
    ];

    users = {
      users = {
        "electrs" = {
          home = "/var/lib/electrs";
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
