{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.security;
  pass = pkgs.pass.withExtensions (exts: with exts; [
    pass-audit
    pass-otp
    pass-update
    pass-tomb
  ]);

in
{ options.modules.user.security = { enable = mkEnableOption "Enable security module"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pass
      wireguard-tools
      ipscan
    ];
  };
}
