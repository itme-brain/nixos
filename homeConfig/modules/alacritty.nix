{ pkgs, lib, config, ... }:

with lib;
let 
  cfg = config.modules.alacritty;

in 
{ options.modules.alacritty = { enable = mkEnableOption "alacritty"; };
  config = mkIf cfg.enable {
    programs.alacritty = {
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
            background = 0x0d1117;
            foreground = 0xb3b1ad;
          };

          normal = {
            black   =  0x484f58;
            red     =  0xff7b72;
            green   =  0x3fb950;
            yellow  =  0xd29922;
            blue    =  0x58a6ff;
            magenta =  0xbc8cff;
            cyan    =  0x39c5cf;
            white   =  0xb1bac4;
          };

          bright = {
            black   =  0x6e7681; 
            red     =  0xffa198;
            green   =  0x56d364;
            yellow  =  0xe3b341;
            blue    =  0x79c0ff;
            magenta =  0xd2a8ff;
            cyan    =  0x56d4dd;
            white   =  0xf0f6fc;
          };
        };  

        font = {
          normal = {
            family = terminus-nerdfont;
            style = Medium;
          };

          bold = {
            family = terminus-nerdfont;
            style = Bold;
          };

          italic = {
            family = terminus-nerdfont;
            style = Medium Italic;
          };

          bold_italic = {
            family = terminus-nerdfont;
            style = Bold Italic;
          };
        };

        size = 14;

        cursor = {
          color = 0xffffff;
          style = {
            shape = Block;
            blinking = Always;
            blink-interval = 750;
          };
        };
      };
    };

    home.packages = with pkgs; [
      terminus-nerdfont
      ranger
      highlight
    ];
  };
}
