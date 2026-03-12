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
        web = {
          bind_address = "127.0.0.1";
          port = 5000;
        };
        mqtt.enabled = false;
        cameras = {
          "Doorbell" = {
            ffmpeg = {
              inputs = [
                {
                  path = "rtsp://admin:ocu?u3Su@192.168.0.134/cam/realmonitor?channel=1&subtype=0";
                  roles = [ "record" ];
                }
                {
                  path = "rtsp://admin:ocu?u3Su@192.168.0.134/cam/realmonitor?channel=1&subtype=1";
                  roles = [ "detect" ];
                }
              ];
            };
          };
          "Living Room" = {
            ffmpeg = {
              inputs = [
                {
                  path = "rtsp://admin:ocu?u3Su@192.168.0.181/cam/realmonitor?channel=1&subtype=0";
                  roles = [ "record" ];
                }
                {
                  path = "rtsp://admin:ocu?u3Su@192.168.0.181/cam/realmonitor?channel=1&subtype=1";
                  roles = [ "detect" ];
                }
              ];
            };
          };
          "Kitchen" = {
            ffmpeg = {
              inputs = [
                {
                  path = "rtsp://admin:ocu?u3Su@192.168.0.181/cam/realmonitor?channel=2&subtype=0";
                  roles = [ "record" ];
                }
                {
                  path = "rtsp://admin:ocu?u3Su@192.168.0.181/cam/realmonitor?channel=2&subtype=1";
                  roles = [ "detect" ];
                }
              ];
            };
          };
          "Parking Lot" = {
            ffmpeg = {
              inputs = [
                {
                  path = "rtsp://admin:ocu?u3Su@192.168.0.60/cam/realmonitor?channel=1&subtype=0";
                  roles = [ "record" ];
                }
                {
                  path = "rtsp://admin:ocu?u3Su@192.168.0.60/cam/realmonitor?channel=1&subtype=1";
                  roles = [ "detect" ];
                }
              ];
            };
          };
          "Porch" = {
            ffmpeg = {
              inputs = [
                {
                  path = "rtsp://admin:ocu?u3Su@192.168.0.108/cam/realmonitor?channel=1&subtype=0";
                  roles = [ "record" ];
                }
                {
                  path = "rtsp://admin:ocu?u3Su@192.168.0.108/cam/realmonitor?channel=1&subtype=1";
                  roles = [ "detect" ];
                }
              ];
            };
          };
        };
      };
    };

    services.nginx.virtualHosts."frigate.${domain}" = mkIf nginx.enable {
      useACMEHost = domain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5000";
        proxyWebsockets = true;
      };
    };
  };
}
