{ lib, config, ... }:

with lib;
let
  cfg = config.modules.system.tor.relay;
  torCfg = config.modules.system.tor;

in
{ options.modules.system.tor.relay = { enable = mkEnableOption "system.tor.relay"; };
  config = mkIf (cfg.enable && torCfg.enable) {
    services.tor = {
      client.enable = false;
      relay.enable = true;
    };
  };
}
