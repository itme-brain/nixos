{ pkgs, lib, ... }:

{
  enable = true;
  settings = {
    scrolling = {
      history = 10000;
      multiplier = 3;
    };

    window = {
      opacity = 0.95;
    };

    colors = {
      primary = {
        background = "#0d1117";
        foreground = "#b3b1ad";
      };

      normal = {
        black   = "#484f58";
        red     = "#ff7b72";
        green   = "#3fb950";
        yellow  = "#d29922";
        blue    = "#58a6ff";
        magenta = "#bc8cff";
        cyan    = "#39c5cf";
        white   = "#b1bac4";
      };

      bright = {
        black   =  "#6e7681";
        red     =  "#ffa198";
        green   =  "#56d364";
        yellow  =  "#e3b341";
        blue    =  "#79c0ff";
        magenta =  "#d2a8ff";
        cyan    =  "#56d4dd";
        white   =  "#f0f6fc";
      };
    };  

    font = {
      normal = {
        family = "Terminus (TTF)";
        style = "Regular";
      };

      bold = {
        family = "Terminus (TTF)";
        style = "Bold";
      };

      italic = {
        family = "Terminus (TTF)";
        style = "Italic";
      };

      bold_italic = {
        family = "Terminus (TTF)";
        style = "Bold Italic";
      };
    };

    size = 14;

    cursor = {
      color = "#ffffff";
      style = {
        shape = "Block";
        blinking = "Always";
        blink_interval = 750;
      };
    };
  };
}
