{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.frigate;
  nginx = config.modules.system.nginx;

in
{ options.modules.system.frigate = { enable = mkEnableOption "Enable Frigate NVR"; };
  config = mkIf cfg.enable {
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
            ffpmeg.inputs = [
              {
                path = "rtsp://$(cat /run/secrets/camera_user):$(cat /run/secrets/camera_pass)@192.168.0.108/cam/realmonitor?channel=1&subtype=0";
                roles = [ "detect" "record" ];
              }
            ];
          };

          "Living Room" = {
            ffpmeg.inputs = [
              {
                path = "rtsp://admin:th3bigbl4ck@192.168.0.181/cam/realmonitor?channel=1&subtype=0";
                roles = [ "detect" "record" ];
              }
            ];
          };

          "Kitchen" = {
            ffpmeg.inputs = [
              {
                path = "rtsp://admin:th3bigbl4ck@192.168.0.181/cam/realmonitor?channel=2&subtype=0";
                roles = [ "detect" "record" ];
              }
            ];
          };

          "Parking Lot" = {
            ffpmeg.inputs = [
              {
                path = "rtsp://admin:th3bigbl4ck@192.168.0.59/cam/realmonitor?channel=1&subtype=0";
                roles = [ "detect" "record" ];
              }
            ];
          };

          "Porch" = {
            ffpmeg.inputs = [
              {
                path = "rtsp://admin:th3bigbl4ck@192.168.0.108/cam/realmonitor?channel=1&subtype=0";
                roles = [ "detect" "record" ];
              }
            ];
          };
        };
      };
    };
  };
}
