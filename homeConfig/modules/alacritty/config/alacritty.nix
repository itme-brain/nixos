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
        background = "#0D1117";
        foreground = "#CDD6F4";
      };

      cursor = {
        text = "#1E1E2E";
        cursor = "#F5E0DC";
      };

      search = {
        matches = {
          foreground = "#1E1E2E";
          background = "#A6ADC8";
        };
        focused_match = {
          foreground = "#1E1E2E";
          background = "#A6E3A1";
        };
        footer_bar = {
          foreground = "#1E1E2E";
          background = "#A6ADC8";
        };
      };

      hints = {
        start = {
          foreground = "#1E1E2E";
          background = "#F9E2AF";
        };
        end = {
          foreground = "#1E1E2E";
          background = "#A6ADC8";
        };
      };

      selection = {
        text = "#1E1E2E";
        background = "#F5E0DC";
      };

      normal = {
        black = "#45475A";
        red = "#F38BA8";
        green = "#A6E3A1";
        yellow = "#F9E2AF";
        blue = "#89B4FA";
        magenta = "#F5C2E7";
        cyan = "#94E2D5";
        white = "#BAC2DE";
      };

      bright = {
        black = "#585B70";
        red = "#F38BA8";
        green = "#A6E3A1";
        yellow = "#F9E2AF";
        blue = "#89B4FA";
        magenta = "#F5C2E7";
        cyan = "#94E2D5";
        white = "#A6ADC8";
      };

      dim = {
        black = "#45475A";
        red = "#F38BA8";
        green = "#A6E3A1";
        yellow = "#F9E2AF";
        blue = "#89B4FA";
        magenta = "#F5C2E7";
        cyan = "#94E2D5";
        white = "#BAC2DE";
      };
    };  

    font = {
      normal = {
        family = "Terminus";
        style = "Regular";
      };

      bold = {
        family = "Terminus";
        style = "Bold";
      };

      italic = {
        family = "Terminus";
        style = "Italic";
      };

      bold_italic = {
        family = "Terminus";
        style = "Bold Italic";
      };

      fallback = [
        { family = "Noto Color Emoji"; }
      ];
    };

    size = 16;

    cursor = {
      color = "#F5E0DC";
      style = {
        shape = "Block";
        blinking = "Always";
        blink_interval = 750;
      };
    };
  };
}
