{ pkgs, lib, config, ... }:

with lib;
let 
  cfg = config.modules.alacritty;

in 
{ options.modules.alacritty = { enable = mkEnableOption "alacritty"; };
  config = mkIf cfg.enable {
    programs.alacritty = import ./config/alacritty.nix { inherit pkgs; };

    home.packages = with pkgs; [
      terminus-nerdfont
      ranger
      highlight
    ];
  };
}
