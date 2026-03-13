{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.bitcoin;
  nginx = config.modules.system.nginx;

  home = "/var/lib/bitcoin";

  bitcoinConf = pkgs.writeTextFile {
    name = "bitcoin.conf";
    text = builtins.readFile ./config/bitcoin.conf;
  };

in
{ options.modules.system.bitcoin = { enable = mkEnableOption "Bitcoin Server"; };
  config = mkIf cfg.enable {
    modules.system.tor.enable = true;

    environment.systemPackages = with pkgs; [
      bitcoind
    ];

    users = {
      users = {
        "btc" = {
          inherit home;
          description = "Bitcoin Core system user";
          isSystemUser = true;
          group = "bitcoin";
          extraGroups = [ "tor" ];
          createHome = true;
        };
        "nginx" = {
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
      "mainnet" = {
        enable = true;
        user = "btc";
        group = "bitcoin";
        configFile = bitcoinConf;
        dataDir = home;
        pidFile = "${home}/bitcoind.pid";
      };
    };

    # Make data dir group-accessible so electrs/clightning can read cookie
    systemd.tmpfiles.rules = [
      "d ${home} 0750 btc bitcoin -"
    ];

    systemd.services.bitcoind-mainnet = {
      wants = [ "tor.service" ];
      after = [ "tor.service" ];
    };

    modules.system.backup.paths = [
      "${home}/wallets"
    ];
  };
}
