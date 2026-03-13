{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.modules.system.bitcoin.electrum;
  nginx = config.modules.system.nginx;
  home = "/var/lib/electrs";

  btc = config.modules.system.bitcoin;
  domain = "ramos.codes";

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
      wantedBy = [ "multi-user.target" ];

      wants = [ "bitcoind-mainnet.service" ];
      after = [
        "bitcoind-mainnet.service"
        "network.target"
      ];

      serviceConfig = {
        ExecStart = "${pkgs.electrs}/bin/electrs --conf=${electrsConfig}";
        User = "electrs";
        Group = "bitcoin";
        WorkingDirectory = home;

        Type = "simple";
        KillMode = "process";
        TimeoutSec = 60;
        Restart = "always";
        RestartSec = 60;
      };
    };

    # Ensure db directory exists with correct permissions
    systemd.tmpfiles.rules = [
      "d ${home} 0750 electrs bitcoin -"
    ];

    # Nginx SSL proxy for Electrum protocol (TCP)
    networking.firewall.allowedTCPPorts = mkIf nginx.enable [ 50002 ];

    services.nginx.streamConfig = mkIf nginx.enable ''
      map $ssl_preread_server_name $electrs_backend {
        electrum.${domain}  127.0.0.1:50001;
        default             "";
      }

      server {
        listen 50002 ssl;
        ssl_preread on;
        proxy_pass $electrs_backend;

        ssl_certificate /var/lib/acme/${domain}/fullchain.pem;
        ssl_certificate_key /var/lib/acme/${domain}/key.pem;
      }
    '';
  };
}
