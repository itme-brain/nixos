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
    # go2rtc service (required - NixOS frigate doesn't bundle it)
    services.go2rtc = {
      enable = true;
      settings = {
        rtsp.listen = ":8554";
        webrtc.listen = ":8555";
        streams = {
          #doorbell = "rtsp://admin:ocu%3Fu3Su@192.168.1.167/cam/realmonitor?channel=1&subtype=0";
          living_room = "rtsp://admin:ocu%3Fu3Su@192.168.1.147/cam/realmonitor?channel=1&subtype=0";
          kitchen = "rtsp://admin:ocu%3Fu3Su@192.168.1.147/cam/realmonitor?channel=2&subtype=0";
          parking_lot = "rtsp://admin:ocu%3Fu3Su@192.168.1.194/cam/realmonitor?channel=1&subtype=0";
          parking_lot_sub = "rtsp://admin:ocu%3Fu3Su@192.168.1.194/cam/realmonitor?channel=1&subtype=1";
          #porch = "rtsp://admin:ocu%3Fu3Su@192.168.0.43/cam/realmonitor?channel=1&subtype=0";
        };
      };
    };

    services.frigate = {
      enable = true;
      hostname = "frigate.${domain}";
      vaapiDriver = "i965";  # Haswell iGPU for H.264 decode
      settings = {
        mqtt.enabled = false;

        ffmpeg = {
          hwaccel_args = "preset-vaapi";  # VAAPI for H.264 substream detection
          input_args = "preset-rtsp-restream";  # TCP transport for go2rtc
        };

        record = {
          enabled = true;
          # 24/7 recording - needs better hardware
          # retain = {
          #   days = 14;
          #   mode = "all";
          # };
        };
        cameras = {
          doorbell = {
            enabled = false;  # Camera offline
            detect.enabled = false;
            ffmpeg.inputs = [{
              path = "rtsp://127.0.0.1:8554/doorbell";
              roles = [ "record" ];
            }];
          };
          living_room = {
            enabled = false;
            detect.enabled = false;
            ffmpeg.inputs = [{
              path = "rtsp://127.0.0.1:8554/living_room";
              roles = [ "record" ];
            }];
          };
          kitchen = {
            enabled = false;
            detect.enabled = false;
            ffmpeg.inputs = [{
              path = "rtsp://127.0.0.1:8554/kitchen";
              roles = [ "record" ];
            }];
          };
          parking_lot = {
            enabled = true;
            detect = {
              enabled = true;
              width = 640;
              height = 480;
            };
            ffmpeg.inputs = [
              {
                path = "rtsp://127.0.0.1:8554/parking_lot";
                roles = [ "record" ];
              }
              {
                path = "rtsp://127.0.0.1:8554/parking_lot_sub";
                roles = [ "detect" ];
              }
            ];
            # Live view stream selector (dropdown in UI)
            live.streams = {
              "HD (HEVC)" = "parking_lot";
              "SD (H.264)" = "parking_lot_sub";
            };
          };
          porch = {
            enabled = false;
            detect.enabled = false;
            ffmpeg.inputs = [{
              path = "rtsp://127.0.0.1:8554/porch";
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

    # Frigate segment cache in RAM (reduces disk writes)
    fileSystems."/var/cache/frigate" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "size=512M" "mode=0755" ];
    };

    systemd.tmpfiles.rules = [
      # Set ownership after tmpfs mount
      "d /var/cache/frigate 0750 frigate frigate -"
    ];

    # Backup recordings/database
    modules.system.backup = {
      paths = [ "/var/lib/frigate" ];
    };

  };
}
