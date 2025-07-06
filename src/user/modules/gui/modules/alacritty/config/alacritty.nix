{ config, ... }:

let
hyprland = config.modules.user.gui.wm.hyprland;

in
{
  scrolling = {
    history = 10000;
    multiplier = 3;
  };

  window = {
    opacity = if hyprland.enable then 0.9 else 1;
  };

  keyboard.bindings = [
    {
      key = "Enter";
      mods = "Alt | Shift";
      action = "SpawnNewInstance";
    }
  ];

  colors = {
    primary = {
      background = "#000000";
      foreground = "#cdd6f4";
    };

    normal = {
      black   = "#1e2127";
      red     = "#e06c75";
      green   = "#98c379";
      yellow  = "#d19a66";
      blue    = "#61afef";
      magenta = "#c678dd";
      cyan    = "#56b6c2";
      white   = "#abb2bf";
    };

    bright = {
      black   =  "#5c6370";
      red     =  "#e06c75";
      green   =  "#98c379";
      yellow  =  "#d19a66";
      blue    =  "#61afef";
      magenta =  "#c678dd";
      cyan    =  "#56b6c2";
      white   =  "#ffffff";
    };
  };

  font = {
    size = 12;
    normal = {
      family = "Terminess Nerd Font Mono";
      style = "Regular";
    };

    bold = {
      family = "Terminess Nerd Font Mono";
      style = "Bold";
    };

    italic = {
      family = "Terminess Nerd Font Mono";
      style = "Italic";
    };

    bold_italic = {
      family = "Terminess Nerd Font Mono";
      style = "Bold Italic";
    };
  };


  #cursor = {
  #  shape = "Block";
  #  blinking = "Always";
  #  blink_interval = 750;
  #};
}
