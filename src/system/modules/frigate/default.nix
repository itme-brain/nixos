{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.frigate;
  nginx = config.modules.system.nginx;
  domain = "ramos.codes";

in
{
  options.modules.system.frigate = {
    enable = mkEnableOption "Enable Frigate NVR";
  };

  config = mkIf cfg.enable {
    services.frigate = {
      enable = true;
      hostname = "frigate.${domain}";
      # vaapiDriver = "i965";  # Haswell only supports H.264, not HEVC
      settings = {
        mqtt.enabled = false;
        # ffmpeg.hwaccel_args = "preset-vaapi";  # Disabled - camera uses HEVC which Haswell can't decode
        cameras = {
          doorbell = {
            enabled = false;
            detect.enabled = false;
            ffmpeg.inputs = [{
              path = "rtsp://admin:ocu?u3Su@192.168.0.134/cam/realmonitor?channel=1&subtype=0";
              roles = [ "record" ];
            }];
          };
          living_room = {
            enabled = false;
            detect.enabled = false;
            ffmpeg.inputs = [{
              path = "rtsp://admin:ocu?u3Su@192.168.0.181/cam/realmonitor?channel=1&subtype=0";
              roles = [ "record" ];
            }];
          };
          kitchen = {
            enabled = false;
            detect.enabled = false;
            ffmpeg.inputs = [{
              path = "rtsp://admin:ocu?u3Su@192.168.0.181/cam/realmonitor?channel=2&subtype=0";
              roles = [ "record" ];
            }];
          };
          parking_lot = {
            enabled = true;
            detect.enabled = false;
            ffmpeg.inputs = [{
              path = "rtsp://admin:ocu?u3Su@192.168.1.194/cam/realmonitor?channel=1&subtype=0";
              roles = [ "record" ];
            }];
          };
          porch = {
            enabled = false;
            detect.enabled = false;
            ffmpeg.inputs = [{
              path = "rtsp://admin:ocu?u3Su@192.168.0.43/cam/realmonitor?channel=1&subtype=0";
              roles = [ "record" ];
            }];
          };
        };
      };
    };

    # Add SSL to frigate's nginx virtualHost
    services.nginx.virtualHosts."frigate.${domain}" = mkIf nginx.enable {
      useACMEHost = domain;
      forceSSL = true;
    };

    # Store frigate data on /data instead of root
    systemd.tmpfiles.rules = [
      "d /data/frigate 0750 frigate frigate -"
      "d /data/frigate/lib 0750 frigate frigate -"
      "d /data/frigate/cache 0750 frigate frigate -"
      "d /data/frigate/nginx-cache 0750 nginx nginx -"
    ];

    fileSystems."/var/lib/frigate" = {
      device = "/data/frigate/lib";
      options = [ "bind" ];
    };

    fileSystems."/var/cache/frigate" = {
      device = "/data/frigate/cache";
      options = [ "bind" ];
    };

    fileSystems."/var/cache/nginx/frigate" = {
      device = "/data/frigate/nginx-cache";
      options = [ "bind" ];
    };

    # Backup recordings/database, exclude caches
    modules.system.backup = {
      paths = [ "/data/frigate" ];
      exclude = [ "*/cache" "*/nginx-cache" ];
    };

  };
}
