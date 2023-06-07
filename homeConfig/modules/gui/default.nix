{ pkgs, lib, config, ... }:

with lib;
let 
  cfg = config.modules.gui;
  
in 
{ options.modules.gui = { enable = mkEnableOption "gui"; };
  config = mkIf cfg.enable {
    wayland.windowManager.sway = import ./config/sway.nix { inherit pkgs config lib; };
    programs.rofi = import ./config/rofi.nix { inherit pkgs config lib; };

    gtk = {
      enable = true;
      theme.package = pkgs.juno-theme;
      theme.name = "Juno-ocean";
      iconTheme.package = pkgs.qogir-icon-theme;
      iconTheme.name = "Qogir";
    };

    qt = {
      enable = true;
      style.package = pkgs.juno-theme;
      platformTheme = "gtk";
    };

    programs.btop.enable = true;
    fonts.fontconfig.enable = true;
  
    home.packages = with pkgs; [
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
