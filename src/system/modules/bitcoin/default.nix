{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.bitcoin;

in
{ options.modules.system.bitcoin = { enable = mkEnableOption "system.bitcoin"; };

  imports = [
    ./core-lightning
    ./sparrow-cli
  ];

  config = mkIf cfg.enable {
    programs.bash.shellAliases = {
      btc = "bitcoin-cli";
    };

    users = {
      users = {
        "bitcoind" = {
          description = "bitcoind system user";
          isSystemUser = true;
          group = "bitcoin";
        };
      };
      groups = {
        "bitcoin" = {
          members = [ "clightning" "electrs" ];
        };
      };
    };

    services.bitcoind = {
      "bitcoind" = {
        enable = true;
        testnet = false;
        user = "bitcoind";
        group = "bitcoin";
        configFile = /var/lib/bitcoind/bitcoin.conf;

        rpc = {
          "btcd" = {
            #passwordHMAC = #CHECK IF THIS IS SAFE TO EXPOSE!!;
          };
          port = 8332;
        };

        extraConfig = ''
          server=1
          mempoolfullrbf=1
          v2transport=1

          rpcbind=127.0.0.1
          rpcallowip=127.0.0.1

          proxy=127.0.0.1:9050
          listen=1
          listenonion=1
          torcontrol=127.0.0.1:9051
          torenablecircuit=1
        '';
      };
    };
  };
}
