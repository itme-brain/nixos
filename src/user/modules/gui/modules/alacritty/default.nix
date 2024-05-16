{ lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.alacritty;
  gui = config.modules.user.gui.wm;

  wm = {
    enable = builtins.any (mod: mod.enable or false) (builtins.attrValues gui);
  };

in
{ options.modules.user.gui.alacritty = { enable = mkEnableOption "user.gui.alacritty"; };
  config = mkIf (cfg.enable && wm.enable) {
    programs.alacritty = {
      enable = true;
      settings = import ./config/alacritty.nix;
    };
  };
}
