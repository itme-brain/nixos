{ lib, config, ... }:

{
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
    pinentryFlavor = "tty";
  };
}
