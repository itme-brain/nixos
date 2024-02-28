{ lib, config, ... }:

with lib;
let
  cfg = config.modules.gui.alacritty;

in
{ options.modules.gui.alacritty = { enable = mkEnableOption "gui.alacritty"; };
  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = import ./config/alacritty.nix;
    };
  };
}
