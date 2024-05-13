{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.bitcoin;
  version = "27.0";

  home = /var/lib/bitcoind;
  conf = pkgs.writeText "bitcoin.conf" (import ./config);

  tor = config.modules.system.tor;

in
{ options.modules.system.bitcoin = { enable = mkEnableOption "system.bitcoin"; };
  config = mkIf (cfg.enable && tor.enable) {
    imports = [ ./modules ];
    nixpkgs.overlays = [
      (final: prev: {
        bitcoind = prev.bitcoind.overrideAttrs (old: {
          src = fetchTarball {
            url = ''
              https://bitcoincore.org/bin/bitcoin-core-${version}/bitcoin-${version}-x86_64-linux-gnu.tar.gz
            '';
            sha256 = ''
              sha256-05i4zrdwr2rnbimf4fmklbm1mrvxg1bnv3yrrx44cp66ba0nd3jg
            '';
          };
        });
      })
    ];

    users = {
      users = {
        "bitcoind" = {
          inherit home;
          description = "bitcoind system user";
          isSystemUser = true;
          group = "bitcoin";
          createHome = true;
        };
      };
      groups = {
        "bitcoin" = {
          members = [
            "clightning"
            "electrs"
          ];
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 8333 ];

    services.bitcoind = {
      "bitcoind" = {
        enable = true;
        user = "bitcoind";
        group = "bitcoin";
        configFile = conf;

        rpc = {
          port = 8332;
          users = {
            config.user.name = {
              passwordHMAC = "";
            };
          };
        };
      };
    };
  };
}
