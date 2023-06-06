{ pkgs, lib, config, ... }:

with lib;
let 
  cfg = config.modules.corn;

in 
{ options.modules.corn = { enable = mkEnableOption "corn"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      trezor-suite trezorctl 
      electrum bisq-desktop
    ];
  };
}
