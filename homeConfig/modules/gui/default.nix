{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.gui;

in
{ options.modules.gui = { enable = mkEnableOption "gui"; };
  imports = [ ./modules ];
  config = mkIf cfg.enable {
    wayland.windowManager.sway = import ./config/sway.nix { inherit pkgs config lib; };
    programs.rofi = import ./config/rofi.nix { inherit pkgs config lib; };
    programs.bash.profileExtra = import ./config/shellHook.nix;

    modules = {
      alacritty.enable = true;
      browsers.enable = true;
      corn.enable = true;
      fun.enable = true;
      guiUtils.enable = true;
      neovim.enable = true;
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

    programs = {
      imv.enable = true;
    };

    fonts.fontconfig.enable = true;
  };
}
