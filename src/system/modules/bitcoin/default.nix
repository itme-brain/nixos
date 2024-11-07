{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.bitcoin;

  home = "/var/lib/bitcoind";

  bitcoinConf = pkgs.writeTextFile {
    name = "bitcoin.conf";
    text = builtins.readFile ./config/bitcoin.conf;
  };

in
{ options.modules.system.bitcoin = { enable = mkEnableOption "Bitcoin Server"; };
  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        bitcoind = prev.bitcoind.overrideAttrs (old: rec {
          version = "27.0";
          src = fetchTarball {
            url = "https://github.com/bitcoin/bitcoin/archive/refs/tags/v${version}.tar.gz";
            sha256 = "sha256-U2tR3WySD3EssA3a14wUtA3e0t/5go0isqNZSSma7m4=";
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

    networking.firewall.allowedTCPPorts = [ 8333 ];

    services.bitcoind = {
      "btc" = {
        enable = true;
        user = "btc";
        group = "bitcoin";
        configFile = bitcoinConf;
        dataDir = home;
        pidFile = "${home}/bitcoind.pid";
      };
    };
  };
}
