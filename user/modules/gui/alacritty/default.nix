{ lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.alacritty;

in
{ options.modules.user.gui.alacritty = { enable = mkEnableOption "Enable Alacritty terminal"; };
  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = import ./config/alacritty.nix { inherit config; };
    };
  };
}
