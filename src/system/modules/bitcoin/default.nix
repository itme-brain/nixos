{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.bitcoin;

in
{ options.modules.bitcoin = { enable = mkEnableOption "bitcoin"; };

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
        #extraConfig = TODO;
      };
    };
  };
}
