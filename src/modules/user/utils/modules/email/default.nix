{ lib, config, ... }:

with lib;
let
  cfg = config.modules.utils.email;

in
{ options.modules.utils.email = { enable = mkEnableOption "utils.email"; };
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
