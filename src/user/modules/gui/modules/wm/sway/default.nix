{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.wm.sway;

in
{ options.modules.user.gui.wm.sway = { enable = mkEnableOption "user.gui.wm.sway"; };
  config = mkIf cfg.enable {
    wayland.windowManager.sway = import ./config/sway.nix { inherit pkgs config lib; };
    programs.rofi = import ./config/rofi { inherit pkgs config lib; };

    home.file.".config/rofi" = {
      source = ./config/rofi/config;
      recursive = true;
    };

    #gtk = {
    #  enable = true;
    #  theme.package = pkgs.juno-theme;
    #  theme.name = "Juno-ocean";
    #  iconTheme.package = pkgs.qogir-icon-theme;
    #  iconTheme.name = "Qogir";
    #};

    qt = {
      enable = true;
      style.package = pkgs.juno-theme;
      platformTheme.name = "gtk";
    };

    home.packages = with pkgs; [
      pavucontrol
      xdg-utils
      wl-clipboard
      autotiling

      grim
      jq
      slurp

      ranger
      highlight

      terminus-nerdfont
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];

    programs = {
      imv.enable = true;
    };

    fonts.fontconfig.enable = true;
  };
}
