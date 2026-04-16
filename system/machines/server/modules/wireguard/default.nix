{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.wireguard;
in
{
  options.modules.system.wireguard = {
    enable = mkEnableOption "WireGuard VPN";

    address = mkOption {
      type = types.str;
      default = "10.8.0.1/24";
      description = "WireGuard interface address with CIDR";
    };

    subnet = mkOption {
      type = types.str;
      default = "10.8.0.0/24";
      description = "WireGuard subnet used for peer allocations";
    };

    listenPort = mkOption {
      type = types.port;
      default = 51820;
      description = "WireGuard UDP listen port";
    };

    privateKeyFile = mkOption {
      type = types.str;
      default = "/var/lib/wireguard/server.key";
      description = "Path to WireGuard server private key";
    };

    peers = mkOption {
      type = types.listOf (types.submodule ({ ... }: {
        options = {
          publicKey = mkOption {
            type = types.str;
            description = "Peer public key";
          };

          allowedIPs = mkOption {
            type = types.listOf types.str;
            description = "Allowed IPs for peer, usually a single /32";
          };

          presharedKeyFile = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Optional preshared key file";
          };

          persistentKeepalive = mkOption {
            type = types.nullOr types.int;
            default = 25;
            description = "Persistent keepalive interval seconds";
          };
        };
      }));
      default = [ ];
      description = "WireGuard peers";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [ cfg.listenPort ];
    networking.firewall.trustedInterfaces = [ "wg0" ];
    networking.nat.internalInterfaces = mkAfter [ "wg0" ];

    systemd.tmpfiles.rules = [
      "d /var/lib/wireguard 0700 root root -"
    ];

    systemd.services.wireguard-generate-key = {
      description = "Generate WireGuard server key if missing";
      before = [ "wireguard-wg0.service" ];
      wantedBy = [ "wireguard-wg0.service" ];
      serviceConfig = {
        Type = "oneshot";
      };
      path = with pkgs; [ wireguard-tools coreutils ];
      script = ''
        set -euo pipefail

        if [ ! -s "${cfg.privateKeyFile}" ]; then
          umask 077
          wg genkey | tee "${cfg.privateKeyFile}" | wg pubkey > /var/lib/wireguard/server.pub
        elif [ ! -s /var/lib/wireguard/server.pub ]; then
          umask 077
          wg pubkey < "${cfg.privateKeyFile}" > /var/lib/wireguard/server.pub
        fi
      '';
    };

    networking.wireguard.interfaces.wg0 = {
      ips = [ cfg.address ];
      listenPort = cfg.listenPort;
      privateKeyFile = cfg.privateKeyFile;
      peers = map (peer: {
        inherit (peer) publicKey allowedIPs;
        presharedKeyFile = peer.presharedKeyFile;
        persistentKeepalive = peer.persistentKeepalive;
      }) cfg.peers;
    };
  };
}
