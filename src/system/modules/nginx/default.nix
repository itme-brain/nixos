{ lib, config, pkgs, ... }:
#TODO: Finish

with lib;
let
  cfg = config.modules.system.nginx;

in
{ options.modules.system.nginx = { enable = mkEnableOption "system.nginx"; };
  config = mkIf cfg.enable {
    imports = [ ./sites ];
    security.acme = {
      defaults = {
        email = config.user.email;
      };
    };
    services.nginx = {
      enable = true;
      enableReload = true;

      user = "nginx";
      group = "nginx";

      package = pkgs.nginxMainLine;
      config = import ./config;
    };
  };
}
