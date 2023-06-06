{ lib, config, ... }:

with lib;
let cfg = config.modules.gpg;

in 
{ options.modules.gpg = { enable = mkEnableOption "gpg"; };
  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      publicKeys."bryan@ramos.codes" = {
        trust = 5;
        text = import ./config/pubKey.nix;
      };
    };

    programs.ssh.enable = true;
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };
  };
}
