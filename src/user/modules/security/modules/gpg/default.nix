{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.security.gpg;
  gui = config.modules.user.gui.wm;
  wm = {
    enable = builtins.any (mod: mod.enable or false) (builtins.attrValues gui);
  };

in
{ options.modules.user.security.gpg = { enable = mkEnableOption "Enable GPG module"; };
  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      publicKeys = [
        {
          text = "${config.user.keys.pgp.primary}";
          trust = 5;
        }
      ];
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableBashIntegration = true;
      enableScDaemon = true;

      pinentryPackage =
      if wm.enable then
        pkgs.pinentry-gtk2
      else
        pkgs.pinentry-curses;
    };
  };
}
