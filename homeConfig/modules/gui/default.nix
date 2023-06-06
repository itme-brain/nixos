{ pkgs, lib, config, ... }:

with lib;
let 
  cfg = config.modules.gui;

in 
{ options.modules.gui = { enable = mkEnableOption "gui"; };
  config = mkIf cfg.enable {
    wayland.windowmanager.sway = import ./config/sway.nix { inherit pkgs; };
    programs.rofi = import ./config/rofi.nix { inherit pkgs; };

    gtk = {
      enable = true;
      theme.package = pkgs.juno-theme;
      theme.name = "Juno-ocean";
      iconTheme.package = pkgs.qogir-icon-theme;
      iconTheme.name = "Qogir";
    };

    programs.btop.enable = true;
    fonts.fontconfig.enable = true;
  
    home.packages = [
      xdg-utils
      grim
      slurp

      imv
      gimp
      evince

      noto-fonts
      noto-fonts-cjk

      emote 
      emojione
    ];
  };
}
