{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.sway;

in
{ options.modules.user.gui.sway = { enable = mkEnableOption "user.gui.sway"; };
  config = mkIf cfg.enable {
    wayland.windowManager.sway = import ./config/sway.nix { inherit pkgs config lib; };
    programs.rofi = import ./config/rofi.nix { inherit pkgs config lib; };

    programs.bash = {
      profileExtra = import ./config/shellHook.nix;
      shellAliases = {
        open = "xdg-open";
      };
    };

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

    home.packages = with pkgs; [
      xdg-utils
      grim
      slurp
      wl-clipboard
      autotiling

      ranger
      highlight

      terminus-nerdfont
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji

      emote
    ];

    programs = {
      imv.enable = true;
    };

    fonts.fontconfig.enable = true;

    home.file."~/Pictures/wallpapers" = {
      source = ../../wallpapers;
      recursive = true;
    };
  };
}
