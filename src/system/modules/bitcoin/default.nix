{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.bitcoin;
  nginx = config.modules.system.nginx;

  home = "/var/lib/bitcoind";

in
{ options.modules.system.bitcoin = { enable = mkEnableOption "Bitcoin Server"; };
  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        bitcoind = prev.bitcoind.overrideAttrs (old: rec {
          version = "28.0";
          src = fetchTarball {
            url = "https://github.com/bitcoin/bitcoin/archive/refs/tags/v${version}.tar.gz";
            sha256 = "sha256-LLtw6pMyqIJ3IWHiK4P3XoifLojB9yMNMo+MGNFGuRY=";
          };
        });
      })
    ];

    users = {
      users = {
        "btc" = {
          inherit home;
          description = "Bitcoin Core system user";
          isSystemUser = true;
          group = "bitcoin";
          createHome = true;
        };
        "${config.services.nginx.user}" = {
          extraGroups = mkIf nginx.enable [
            "bitcoin"
          ];
        };
      };
      groups = {
        "bitcoin" = {
          members = [
            "btc"
          ];
        };
      };
    };

    programs.bash.shellAliases = {
      btc = "bitcoind";
    };

    services.bitcoind = {
      "btc" = {
        enable = true;
        user = "btc";
        group = "bitcoin";
        configFile = ./config/bitcoin.conf;
        dataDir = home;
        pidFile = "${home}/bitcoind.pid";
      };
    };
  };
}
