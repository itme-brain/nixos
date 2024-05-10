{ lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gpg;

in
{ options.modules.user.gpg = { enable = mkEnableOption "user.gpg"; };
  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      publicKeys = [ config.user.pgpKey ];
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableBashIntegration = true;
      pinentryFlavor = "tty";
    };
  };
}
