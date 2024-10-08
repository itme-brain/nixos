{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.corn;

in
{ options.modules.user.gui.corn = { enable = mkEnableOption "Enable Bitcoin client applications"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      trezor-suite
      trezorctl
      trezord

      sparrow
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
