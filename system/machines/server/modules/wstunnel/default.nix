{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.wstunnel;
in
{
  options.modules.system.wstunnel = {
    enable = mkEnableOption "wstunnel WebSocket transport for WireGuard";

    listenPort = mkOption {
      type = types.port;
      default = 8080;
      description = "Local port wstunnel server listens on (nginx proxies to this)";
    };

    wireguardPort = mkOption {
      type = types.port;
      default = 51820;
      description = "Local WireGuard port to forward traffic to";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.wstunnel = {
      description = "wstunnel WebSocket server for WireGuard transport";
      after = [ "network.target" "wireguard-wg0.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.wstunnel}/bin/wstunnel server ws://127.0.0.1:${toString cfg.listenPort} --restrict-to 127.0.0.1:${toString cfg.wireguardPort}";
        Restart = "on-failure";
        RestartSec = 5;
        DynamicUser = true;
      };
    };
  };
}
