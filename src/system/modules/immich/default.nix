{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.immich;
  nginx = config.modules.system.nginx;
  domain = "ramos.codes";
  port = 2283;

in
{
  options.modules.system.immich = {
    enable = mkEnableOption "Immich Photo Server";
  };

  config = mkIf cfg.enable {
    services.immich = {
      enable = true;
      port = port;
      host = "127.0.0.1";
      mediaLocation = "/var/lib/immich";
      machine-learning.enable = false;
    };

    modules.system.backup.paths = [
      "/var/lib/immich"
    ];

    services.nginx.virtualHosts."photos.${domain}" = mkIf nginx.enable {
      useACMEHost = domain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true;
      };
    };
  };
}
