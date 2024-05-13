{ lib, config, ... }:

with lib;
let
  cfg = config.modules.user.security.gpg;

in
{ options.modules.user.security.gpg = { enable = mkEnableOption "user.security.gpg"; };
  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      publicKeys = [ config.user.pgpKey ];
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableBashIntegration = true;
      enableScDaemon = true;
      pinentryFlavor = "tty";
    };
  };
}
