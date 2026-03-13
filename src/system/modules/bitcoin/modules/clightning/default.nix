{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.modules.system.bitcoin.clightning;
  btc = config.modules.system.bitcoin;
  nginx = config.modules.system.nginx;
  home = "/var/lib/clightning";
  domain = "ramos.codes";

  clnConfig = pkgs.writeTextFile {
    name = "lightning.conf";
    text = ''
      ${builtins.readFile ./config/lightning.conf}
      bitcoin-cli=${pkgs.bitcoind}/bin/bitcoin-cli
    '';
  };

in
{ options.modules.system.bitcoin.clightning = { enable = mkEnableOption "Core Lightning Server"; };
  config = mkIf (cfg.enable && btc.enable) {
    environment.systemPackages = with pkgs; [
      clightning
    ];

    users = {
      users = {
        "clightning" = {
          inherit home;
          description = "Core Lightning system user";
          isSystemUser = true;
          group = "bitcoin";
          extraGroups = [ "tor" ];
          createHome = true;
        };
      };
      groups = {
        "bitcoin" = {
          members = mkAfter [
            "clightning"
          ];
        };
      };
    };

    programs.bash.shellAliases = {
      cln = "lightning-cli";
    };

    systemd.services.lightningd = {
      description = "Core Lightning Daemon";
      wantedBy = [ "multi-user.target" ];

      wants = [ "bitcoind-mainnet.service" "tor.service" ];
      after = [
        "bitcoind-mainnet.service"
        "tor.service"
        "network.target"
      ];

      serviceConfig = {
        ExecStart = "${pkgs.clightning}/bin/lightningd --conf=${clnConfig}";
        User = "clightning";
        Group = "bitcoin";
        WorkingDirectory = home;

        Type = "simple";
        KillMode = "process";
        TimeoutSec = 60;
        Restart = "always";
        RestartSec = 60;
      };
    };

    # Ensure data directory exists with correct permissions
    systemd.tmpfiles.rules = [
      "d ${home} 0750 clightning bitcoin -"
      "d ${home}/plugins 0750 clightning bitcoin -"
    ];

    modules.system.backup.paths = [
      "${home}/bitcoin/hsm_secret"
    ];

    # TODO: CLNRest not included in nixpkgs clightning build
    # Need to package it separately or use an overlay
    # services.nginx.virtualHosts."ln.${domain}" = mkIf nginx.enable {
    #   useACMEHost = domain;
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "https://127.0.0.1:3010";
    #     extraConfig = ''
    #       proxy_ssl_verify off;
    #     '';
    #   };
    # };
  };
}
