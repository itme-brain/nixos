{ lib, config, ... }:

with lib;
let 
  cfg = config.modules.security;

in 
{ options.modules.security = { enable = mkEnableOption "security"; };
  config = mkIf cfg.enable {
    home.packages = [
      keepassxc wireguard-tools ipscan
    ]; 
  };
}