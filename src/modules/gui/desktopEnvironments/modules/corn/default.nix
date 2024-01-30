{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.gui.corn;

in
{ options.modules.gui.corn = { enable = mkEnableOption "gui.corn"; };
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
