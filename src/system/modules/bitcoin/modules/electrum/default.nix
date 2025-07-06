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
          group = "btc";
          createHome = true;
        };
      };
      groups = {
        "btc" = {
          members = [
            "electrs"
          ];
        };
      };
    };


    systemd.services.electrs = {
      description = "Electrs Bitcoin Indexer";
      serviceConfig = {
        User = "electrs";
        Group = "btc";

        StateDirectory   = "electrs";
        WorkingDirectory = "%S/electrs";

        ExecStart = "${pkgs.electrs}/bin/electrs --conf=${electrsConfig}";

        Type = "simple";
        KillMode = "process";
        TimeoutSec = 60;
        Restart = "on-failure";
        RestartSec = 2;
      };
      after = [
        "network.target"
        "bitcoind-btc.service"
      ];
      requires = [ "bitcoind-btc.service" ];
      partOf = [ "bitcoind-btc.service" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
