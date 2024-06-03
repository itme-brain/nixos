{ config, lib, pkgs, ... }:

{
  enable = true;
  settings = [
    {
      mainBar = {
        font-family = "Terminus";
        font-size = 12;
        background-color = "rgba(10, 14, 20, 1)";
        color = "#FFFFFF";

        layer = "top";
        output = [
          "HDMI-A-1"
        ];

        position = "top";
        height = 10;

        modules-left = [
          "hyprland/workspaces"
          "wlr/taskbar"
        ];

        modules-center = [
          "clock"
        ];

        modules-right = [
          "memory"
          "network"
          "tray"
        ];

        "hyprland/workspaces" = {
          active-only = true;
          format = "{name}";
        };

        "wlr/taskbar" = {
          format = "{icon}";
          icon_size = 14;
          icon-theme = "Qogir";
          tooltip-format = "{title}";
          on-click = "minimize-raise";
          ignore-list = [
            "Alacritty"
            "rofi"
          ];
          rewrite = {
            "Firefox Web Browser" = "Firefox";
          };
        };

        "clock" = {
          format = "%I:%M:%S %p | %m-%d-%Y";
          interval = 60;
        };

        "memory" = {
          format = "RAM: {percentage}%";
          interval = 30;
        };

        "network" = {
          format-disconnected = "<span color=\"#FF0000\">󰜺</span>";
          format-wifi = "<span color=\"##00FF00\">󰖩</span>{essid}({signalStrength}%)";
          format-ethernet = "<span color=\"##00FF00\">󰈁</span>{cidr}";
        };

        "tray" = {
          icon_size = 16;
          spacing = 10;
        };
      };
    }
  ];
}
