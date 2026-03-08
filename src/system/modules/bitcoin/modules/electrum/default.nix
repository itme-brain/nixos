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
    #TODO: Fix the failing overlay due to `cargoHash/cargoSha256`
    #nixpkgs.overlays = [
    #  (final: prev: {
    #    electrs = prev.electrs.overrideAttrs (old: rec {
    #      pname = "electrs";
    #      version = "0.10.8";
    #      src = pkgs.fetchFromGitHub {
    #        owner = "romanz";
    #        repo = pname;
    #        rev = "v${version}";
    #        hash = "sha256-L26jzAn8vwnw9kFd6ciyYS/OLEFTbN8doNKy3P8qKRE=";
    #      };
    #      #cargoDeps = old.cargoDeps.overrideAttrs (const {
    #      #  name = "electrs-${version}.tar.gz";
    #      #  inherit src;
    #      #  sha256 = "";
    #      #});
    #      cargoHash = "sha256-lBRcq73ri0HR3duo6Z8PdSjnC8okqmG5yWeHxH/LmcU=";
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
