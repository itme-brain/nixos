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
          version = "29.0";
          src = fetchTarball {
            url = "https://github.com/bitcoin/bitcoin/archive/refs/tags/v${version}.tar.gz";
            sha256 = "sha256-XvoqYA5RYXbOjeidxV4Wxb8DhYv6Hz510XNMhmWkV1Y=";
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
          group = "btc";
          createHome = true;
        };
        "${config.services.nginx.user}" = {
          extraGroups = mkIf nginx.enable [
            "btc"
          ];
        };
      };
      groups = {
        "btc" = {
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
        group = "btc";
        configFile = ./config/bitcoin.conf;
        dataDir = home;
        pidFile = "${home}/bitcoind.pid";
      };
    };

    services.tor = {
      enable = true;
      client.enable = true;
    };
  };
}
