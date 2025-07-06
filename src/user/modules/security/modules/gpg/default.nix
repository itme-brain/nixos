{ pkgs, lib, config, osConfig, ... }:

with lib;
let
  cfg = config.modules.user.security.gpg;
  wm = config.modules.user.gui.wm;
  gui = {
    enable = builtins.any (mod: mod.enable or false) (builtins.attrValues wm);
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
      ] ++ optionals (osConfig.networking.hostName == "desktop") [
        {
          text = "${config.user.keys.pgp.windows}";
          trust = 5;
        }
      ] ++ optionals (osConfig.networking.hostName == "workstation") [
        {
          text = "${config.user.keys.pgp.work}";
          trust = 5;
        }
        {
          text = "${config.user.keys.pgp.ccur}";
          trust = 5;
        }
      ];
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableBashIntegration = true;
      enableScDaemon = true;

      pinentry.package =
      if gui.enable then
        pkgs.pinentry-gnome3
      else
        pkgs.pinentry-curses;
    };
  };
}
