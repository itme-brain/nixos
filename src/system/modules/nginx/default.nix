{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.system.nginx;

  btc = config.modules.system.bitcoin;
  cln = btc.core-lightning;
  elec = btc.electrum;

in
{ options.modules.system.nginx = { enable = mkEnableOption "system.nginx"; };
  imports = [ ./sites ];
  config = mkIf cfg.enable {
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

    networking.firewall.allowedTCPPorts =
      optionals cln.REST.enable
        [ 9734 ] ++
      optionals elec.enable
        [ 50001 ];
  };
}
