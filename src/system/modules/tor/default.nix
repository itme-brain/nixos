{ lib, config, ... }:
#TODO: Configure tor

with lib;
let
  cfg = config.modules.system.tor;
  home = /var/lib/tor;

in
{ options.modules.system.tor = { enable = mkEnableOption "system.tor"; };
  imports = [ ./modules ];
  config = mkIf cfg.enable {
    services.tor = {
      enable = true;

      client = {
        enable = lib.mkDefault true;
        dns.enable = mkIf services.tor.client.enable true;
      };

      relay.enable = lib.mkDefault false;
      enableGeoIP = false;
      DoSConnectionEnabled = true;
      DoSCircuitCreationEnabled = true;

      settings = {
        DataDirectory = home;
      };
    };
  };
}
