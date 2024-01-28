{ lib, config, ... }:

with lib;
let
  cfg = config.modules.alacritty;

in
{ options.modules.alacritty = { enable = mkEnableOption "alacritty"; };
  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = import ./config/alacritty.nix;
    };
  };
}
