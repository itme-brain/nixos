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
      settings = {
        mqtt.enabled = false;
        cameras = {
          doorbell = {
            detect.enabled = false;
            ffmpeg.inputs = [{
              path = "rtsp://admin:ocu?u3Su@192.168.0.134/cam/realmonitor?channel=1&subtype=0";
              roles = [ "record" ];
            }];
          };
          living_room = {
            detect.enabled = false;
            ffmpeg.inputs = [{
              path = "rtsp://admin:ocu?u3Su@192.168.0.181/cam/realmonitor?channel=1&subtype=0";
              roles = [ "record" ];
            }];
          };
          kitchen = {
            detect.enabled = false;
            ffmpeg.inputs = [{
              path = "rtsp://admin:ocu?u3Su@192.168.0.181/cam/realmonitor?channel=2&subtype=0";
              roles = [ "record" ];
            }];
          };
          parking_lot = {
            detect.enabled = false;
            ffmpeg.inputs = [{
              path = "rtsp://admin:ocu?u3Su@192.168.1.194/cam/realmonitor?channel=1&subtype=0";
              roles = [ "record" ];
            }];
          };
          porch = {
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

  };
}
