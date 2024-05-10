{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.security;

in
{ options.modules.user.security = { enable = mkEnableOption "user.security"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pass
      wireguard-tools
      ipscan
    ];
  };
}
