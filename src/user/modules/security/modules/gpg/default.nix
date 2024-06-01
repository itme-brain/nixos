{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.security.gpg;

in
{ options.modules.user.security.gpg = { enable = mkEnableOption "user.security.gpg"; };
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
      pinentryPackage = pkgs.pinentry-tty;
    };
  };
}
