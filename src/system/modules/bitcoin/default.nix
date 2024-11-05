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
  imports = [ ./modules ];
  config = mkIf cfg.enable {
    #nixpkgs.overlays = [
    #  (final: prev: {
    #    bitcoind = prev.bitcoind.overrideAttrs (old: rec {
    #      version = "v28.0";
    #      src = pkgs.fetchFromGitHub {
    #        owner = "bitcoin";
    #        repo = "bitcoin";
    #        rev = "${version}";
    #        sha256 = "sha256-LLtw6pMyqIJ3IWHiK4P3XoifLojB9yMNMo+MGNFGuRY=";
    #      };
    #    });
    #  })
    #];

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
