{ lib, config, ... }:

with lib;
let
  cfg = config.modules.gpg;
  isBryan = config.user.name == "bryan";

in
{ options.modules.gpg = { enable = mkEnableOption "gpg"; };
  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      publicKeys = if isBryan then [
        {
          text = import ./config/pubKey.nix;
          trust = 5;
        }
      ] else [];
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableBashIntegration = true;
    };
  };
}
