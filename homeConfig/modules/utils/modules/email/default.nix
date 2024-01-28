{ lib, config, ... }:

with lib;
let
  cfg = config.modules.email;

in
{ options.modules.email = { enable = mkEnableOption "email"; };
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
