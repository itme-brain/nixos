{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.corn;

in
{ options.modules.corn = { enable = mkEnableOption "corn"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      trezor-suite
      trezorctl
      trezord

      electrum
      bisq-desktop
    ];

    systemd.user.services = {
      trezord = {
        Unit = {
          Description = "Trezor Bridge";
          After = [ "network.target" ];
          Wants = [ "network.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.trezord}/bin/trezord-go";
          Restart = "always";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
