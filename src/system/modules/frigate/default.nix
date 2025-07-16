{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.frigate;
  nginx = config.modules.system.nginx;

in
{ options.modules.system.frigate = { enable = mkEnableOption "Enable Frigate NVR"; };
  config = mkIf cfg.enable {
    sops = {
      secrets = {
        camera_user = {};
        camera_pass = {};
      };
    };

    services.frigate = {
      enable = true;
      hostname = "frigate";
      settings = {
        mqtt = {
          enabled = true;
          host = "localhost";
        };
        cameras = {
          "Doorbell" = {
            ffmpeg = {
              inputs = [
                {
                  path = "rtsp://user:password@192.168.0.108/cam/realmonitor?channel=1&subtype=0";
                  roles = [ "record" ];
                }
                {
                  path = "rtsp://user:password@192.168.0.108/cam/realmonitor?channel=1&subtype=1";
                  roles = [ "detect" ];
                }
              ];
            };
          };
          "Living Room" = {
            ffmpeg = {
              inputs = [
                {
                  path = "rtsp://user:password@192.168.0.181/cam/realmonitor?channel=1&subtype=0";
                  roles = [ "record" ];
                }
                {
                  path = "rtsp://user:password@192.168.0.181/cam/realmonitor?channel=1&subtype=1";
                  roles = [ "detect" ];
                }
              ];
            };
          };
          "Kitchen" = {
            ffmpeg = {
              inputs = [
                {
                  path = "rtsp://user:password@192.168.0.181/cam/realmonitor?channel=2&subtype=0";
                  roles = [ "record" ];
                }
                {
                  path = "rtsp://user:password@192.168.0.181/cam/realmonitor?channel=2&subtype=1";
                  roles = [ "detect" ];
                }
              ];
            };
          };
          "Parking Lot" = {
            ffmpeg = {
              inputs = [
                {
                  path = "rtsp://user:password@192.168.0.59/cam/realmonitor?channel=1&subtype=0";
                  roles = [ "record" ];
                }
                {
                  path = "rtsp://user:password@192.168.0.59/cam/realmonitor?channel=1&subtype=1";
                  roles = [ "detect" ];
                }
              ];
            };
          };
          "Porch" = {
            ffmpeg = {
              inputs = [
                {
                  path = "rtsp://user:password@192.168.0.108/cam/realmonitor?channel=1&subtype=0";
                  roles = [ "record" ];
                }
                {
                  path = "rtsp://user:password@192.168.0.108/cam/realmonitor?channel=1&subtype=1";
                  roles = [ "detect" ];
                }
              ];
            };
          };
        };
      };
    };
  };
}
