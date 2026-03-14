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
          doorbell = "rtsp://admin:ocu%3Fu3Su@192.168.1.167/cam/realmonitor?channel=1&subtype=0#backchannel=1";
          doorbell_sub = "rtsp://admin:ocu%3Fu3Su@192.168.1.167/cam/realmonitor?channel=1&subtype=1";
          living_room = "rtsp://admin:ocu%3Fu3Su@192.168.1.147/cam/realmonitor?channel=1&subtype=0#backchannel=1";
          living_room_sub = "rtsp://admin:ocu%3Fu3Su@192.168.1.147/cam/realmonitor?channel=1&subtype=1";
          kitchen = "rtsp://admin:ocu%3Fu3Su@192.168.1.147/cam/realmonitor?channel=2&subtype=0#backchannel=1";
          kitchen_sub = "rtsp://admin:ocu%3Fu3Su@192.168.1.147/cam/realmonitor?channel=2&subtype=1";
          parking_lot = "rtsp://admin:ocu%3Fu3Su@192.168.1.194/cam/realmonitor?channel=1&subtype=0";
          parking_lot_sub = "rtsp://admin:ocu%3Fu3Su@192.168.1.194/cam/realmonitor?channel=1&subtype=1";
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

        detect.enabled = true;

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
            enabled = true;
            detect = {
              enabled = true;
              width = 640;
              height = 480;
            };
            ffmpeg.inputs = [
              {
                path = "rtsp://127.0.0.1:8554/doorbell";
                roles = [ "record" ];
              }
              {
                path = "rtsp://127.0.0.1:8554/doorbell_sub";
                roles = [ "detect" ];
              }
            ];
          };
          living_room = {
            enabled = true;
            detect.enabled = false;  # Disable in GUI
            audio.enabled = true;
            motion.mask = [ "0.969,0.078,0.846,0.075,0.845,0.034,0.97,0.037" ];
            ffmpeg.inputs = [
              {
                path = "rtsp://127.0.0.1:8554/living_room";
                roles = [ "record" ];
              }
              {
                path = "rtsp://127.0.0.1:8554/living_room_sub";
                roles = [ "detect" "audio" ];
              }
            ];
          };
          kitchen = {
            enabled = true;
            detect.enabled = false;  # Disable in GUI
            audio.enabled = true;
            motion.mask = [ "0.847,0.072,0.846,0.029,0.969,0.032,0.969,0.072" ];
            ffmpeg.inputs = [
              {
                path = "rtsp://127.0.0.1:8554/kitchen";
                roles = [ "record" ];
              }
              {
                path = "rtsp://127.0.0.1:8554/kitchen_sub";
                roles = [ "detect" "audio" ];
              }
            ];
          };
          parking_lot = {
            enabled = true;
            detect = {
              enabled = true;
              width = 640;
              height = 480;
            };
            motion.mask = [ "0.811,0.109,0.954,0.111,0.959,0.065,0.811,0.055" ];
            zones.Car = {
              coordinates = "0.299,0.438,0.191,0.951,0.453,0.964,0.453,0.437";
              loitering_time = 5;
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
          };
        };
      };
    };

    # Add SSL to frigate's nginx virtualHost
    services.nginx.virtualHosts."frigate.${domain}" = mkIf nginx.enable {
      useACMEHost = domain;
      forceSSL = true;
      locations."/go2rtc/" = {
        proxyPass = "http://127.0.0.1:1984/";
        proxyWebsockets = true;
      };
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
      # Create log directories for Frigate API (NixOS uses journald, but API expects these)
      "d /dev/shm/logs 0755 frigate frigate -"
      "d /dev/shm/logs/frigate 0755 frigate frigate -"
      "d /dev/shm/logs/nginx 0755 frigate frigate -"
      "d /dev/shm/logs/go2rtc 0755 frigate frigate -"
      "f /dev/shm/logs/frigate/current 0644 frigate frigate -"
      "f /dev/shm/logs/nginx/current 0644 frigate frigate -"
      "f /dev/shm/logs/go2rtc/current 0644 frigate frigate -"
    ];

    # Backup recordings/database
    modules.system.backup = {
      paths = [ "/var/lib/frigate" ];
    };

  };
}
