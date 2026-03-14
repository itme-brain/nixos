{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.security.yubikey;

in
{ options.modules.user.security.yubikey = { enable = mkEnableOption "Enable Yubikey support"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      yubikey-manager
      age-plugin-yubikey
      yubico-piv-tool
    ];
  };
}
