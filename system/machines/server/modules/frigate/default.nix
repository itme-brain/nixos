{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.frigate;
  nginx = config.modules.system.nginx;
  domain = "ramos.codes";
  user = config.sops.placeholder."RTSP_USER";
  pass = config.sops.placeholder."RTSP_PASS";

in
{
  options.modules.system.frigate = {
    enable = mkEnableOption "Enable Frigate NVR";
  };

  config = mkIf cfg.enable {
    # Allow user to access frigate recordings via SSHFS
    users.users.${config.user.name}.extraGroups = [ "frigate" ];

    # go2rtc config with credentials from sops
    sops.templates."go2rtc.yaml" = {
      content = ''
        rtsp:
          listen: ":8554"
        webrtc:
          listen: ":8555"
        streams:
          cam1: "rtsp://${user}:${pass}@192.168.1.167/cam/realmonitor?channel=1&subtype=0#backchannel=1"
          cam1_sub: "rtsp://${user}:${pass}@192.168.1.167/cam/realmonitor?channel=1&subtype=1"
          cam2: "rtsp://${user}:${pass}@192.168.1.147/cam/realmonitor?channel=1&subtype=0#backchannel=1"
          cam2_sub: "rtsp://${user}:${pass}@192.168.1.147/cam/realmonitor?channel=1&subtype=1"
          cam3: "rtsp://${user}:${pass}@192.168.1.147/cam/realmonitor?channel=2&subtype=0#backchannel=1"
          cam3_sub: "rtsp://${user}:${pass}@192.168.1.147/cam/realmonitor?channel=2&subtype=1"
          cam4: "rtsp://${user}:${pass}@192.168.1.194/cam/realmonitor?channel=1&subtype=0"
          cam4_sub: "rtsp://${user}:${pass}@192.168.1.194/cam/realmonitor?channel=1&subtype=1"
      '';
      mode = "0444";  # go2rtc runs as dynamic user, needs read access
    };

    # go2rtc service using sops-templated config
    services.go2rtc.enable = true;
    systemd.services.go2rtc = {
      serviceConfig.ExecStart = mkForce "${pkgs.go2rtc}/bin/go2rtc -config ${config.sops.templates."go2rtc.yaml".path}";
      after = [ "sops-nix.service" ];
      wants = [ "sops-nix.service" ];
    };

    services.frigate = {
      enable = true;
      package = pkgs.unstable.frigate;
      hostname = "frigate.${domain}";
      vaapiDriver = "i965";  # Haswell iGPU for H.264 decode
      settings = {
        mqtt.enabled = false;

        ffmpeg = {
          hwaccel_args = "preset-vaapi";  # VAAPI for H.264 substream detection
          input_args = "preset-rtsp-restream";  # TCP transport for go2rtc
        };

        birdseye = {
          mode = "continuous";
          width = 1280;
          height = 720;
          quality = 8; # 8 - 31
        };

        motion = {
          enabled = true;
        };

        detect = {
          enabled = true;
          min_initialized = 3;
          max_disappeared = 25;
          width = 1280;
          height = 720;
        };

        audio = {
          enabled = true;
          max_not_heard = 30;
          min_volume = 600;
          listen = [
            "glass"
            "shatter"
            "fire_alarm"
            "boom"
            "thump"
            "siren"
            "alarm"
            "explosion"
            "burst"
          ];
        };

        audio_transcription.enabled = false;

        record = {
          enabled = true;
          continuous.days = 3;   # Full 24/7 footage
          motion.days = 7;       # Motion segments after continuous expires
          detections.retain = {
            days = 14;           # Any tracked object (person, car, etc.)
            mode = "motion";
          };
          alerts.retain = {
            days = 30;           # Zone violations, loitering - important stuff
            mode = "all";
          };
        };

        snapshots = {
          enabled = true;
          retain = {
            default = 3;
          };
          quality = 80;
        };


        cameras = {
          cam1 = {
            enabled = true;
            ffmpeg.inputs = [
              {
                path = "rtsp://127.0.0.1:8554/cam1";
                roles = [ "record" ];
              }
              {
                path = "rtsp://127.0.0.1:8554/cam1_sub";
                roles = [ "detect" "audio" ];
              }
            ];
          };

          cam2 = {
            enabled = true;
            motion.enabled = false;
            detect.enabled = false;
            objects.mask = [ "0.969,0.078,0.846,0.075,0.845,0.034,0.97,0.037" ];
            ffmpeg.inputs = [
              {
                path = "rtsp://127.0.0.1:8554/cam2";
                roles = [ "record" ];
              }
              {
                path = "rtsp://127.0.0.1:8554/cam2_sub";
                roles = [ "detect" "audio" ];
              }
            ];
          };

          cam3 = {
            enabled = true;
            motion.enabled = false;
            detect.enabled = false;
            ffmpeg.inputs = [
              {
                path = "rtsp://127.0.0.1:8554/cam3";
                roles = [ "record" ];
              }
              {
                path = "rtsp://127.0.0.1:8554/cam3_sub";
                roles = [ "detect" "audio" ];
              }
            ];
          };

          cam4 = {
            enabled = true;
            audio.enabled = false;
            motion.mask = [ "0.811,0.109,0.954,0.111,0.959,0.065,0.811,0.055" ];
            zones.zone1 = {
              friendly_name = "lot";
              coordinates = "0.299,0.438,0.191,0.951,0.453,0.964,0.453,0.437";
              loitering_time = 10;
            };
            ffmpeg.inputs = [
              {
                path = "rtsp://127.0.0.1:8554/cam4";
                roles = [ "record" ];
              }
              {
                path = "rtsp://127.0.0.1:8554/cam4_sub";
                roles = [ "detect" ];
              }
            ];
          };
        };

        classification = {
          custom = {
            "door" = {
              enabled = true;
              name = "door";
              threshold = 0.8;
              state_config = {
                cameras = {
                  cam2.crop = [
                    0.8595647692717828
                    0.39901413156128707
                    0.9903488513256276
                    0.6315191663236775
                  ];
                  cam3.crop = [
                    0.0008617338314475493
                    0.3909394833748086
                    0.12040036569190293
                    0.6034526066822848
                  ];
                };
                motion = true;
              };
            };
            "lot" = {
              enabled = true;
              name = "lot";
              threshold = 0.8;
              state_config = {
                cameras = {
                  cam4.crop = [
                    0.2757899560295573
                    0.5156825410706086
                    0.4445399560295573
                    0.8156825410706086
                  ];
                };
                motion = true;
              };
            };
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
    ];

    # Pipe journald logs to files for Frigate GUI
    systemd.services.frigate-log-pipe = {
      description = "Pipe logs to /dev/shm for Frigate GUI";
      wantedBy = [ "multi-user.target" ];
      after = [ "frigate.service" "go2rtc.service" "nginx.service" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        ExecStart = pkgs.writeShellScript "frigate-log-pipe" ''
          while true; do
            ${pkgs.systemd}/bin/journalctl -u frigate -n 500 -o cat > /dev/shm/logs/frigate/current 2>/dev/null
            ${pkgs.systemd}/bin/journalctl -u go2rtc -n 500 -o cat > /dev/shm/logs/go2rtc/current 2>/dev/null
            ${pkgs.systemd}/bin/journalctl -u nginx -n 500 -o cat > /dev/shm/logs/nginx/current 2>/dev/null
            chown frigate:frigate /dev/shm/logs/*/current
            sleep 5
          done
        '';
      };
    };

    # Backup recordings/database
    modules.system.backup = {
      paths = [ "/var/lib/frigate" ];
    };
  };
}
