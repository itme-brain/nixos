{ lib, config, ... }:

with lib;
let
  cfg = config.modules.user.utils.email;

in
{ options.modules.user.utils.email = { enable = mkEnableOption "user.utils.email"; };
  config = mkIf cfg.enable {
    programs.aerc = {
      enable = true;
    };

    home.file.".config/aerc" = {
      source = ./config;
      recursive = true;
    };
  };
}
