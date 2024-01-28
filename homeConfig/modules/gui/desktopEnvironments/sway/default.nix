{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.sway;

in
{ options.modules.sway = { enable = mkEnableOption "sway"; };
  imports = [ ../modules ];
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

    programs = {
      imv.enable = true;
    };

    home.packages = with pkgs; [
      xdg-utils
      grim
      slurp
      wl-clipboard
      autotiling

      ranger
      highlight
    ];

    fonts.fontconfig.enable = true;

    modules = {
      alacritty.enable = true;
      browsers.enable = true;
      corn.enable = true;
      fun.enable = true;
      guiUtils.enable = true;
      neovim.enable = true;
    };
  };
}
