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
      foreground = "#dadada";
    };

    normal = {
      black   = "#181818";
      red     = "#ff6b6b";
      green   = "#00b300";
      yellow  = "#e8a060";
      blue    = "#88ddcc";
      magenta = "#c490d0";
      cyan    = "#b3f6c0";
      white   = "#dadada";
    };

    bright = {
      black   = "#5a5a5a";
      red     = "#ff6b6b";
      green   = "#00b300";
      yellow  = "#ffcc00";
      blue    = "#88ddcc";
      magenta = "#c490d0";
      cyan    = "#b3f6c0";
      white   = "#ffffff";
    };
  };

  font = {
    size = 12;
    normal = {
      family = "Terminess Nerd Font Propo";
      style = "Regular";
    };

    bold = {
      family = "Terminess Nerd Font Propo";
      style = "Bold";
    };

    italic = {
      family = "Terminess Nerd Font Propo";
      style = "Italic";
    };

    bold_italic = {
      family = "Terminess Nerd Font Propo";
      style = "Bold Italic";
    };
  };


  #cursor = {
  #  shape = "Block";
  #  blinking = "Always";
  #  blink_interval = 750;
  #};
}
