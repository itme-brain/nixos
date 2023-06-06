{ lib, config, ... }:

with lib;
let cfg = config.modules.gpg;

in 
{ options.modules.gpg = { enable = mkEnableOption "gpg"; };
  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      publicKeys = [
        {
          text = import ./config/pubKey.nix;
          trust = 5;
        }
      ];
    };

    programs.ssh.enable = true;
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };
  };
}
