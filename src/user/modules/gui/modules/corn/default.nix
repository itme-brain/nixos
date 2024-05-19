{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.corn;
  gui = config.modules.user.gui.wm;

  wm = {
    enable = builtins.any (mod: mod.enable or false) (builtins.attrValues gui);
  };

in
{ options.modules.user.gui.corn = { enable = mkEnableOption "user.gui.corn"; };
  config = mkIf (cfg.enable && wm.enable) {
    home.packages = with pkgs; [
      trezor-suite
      trezorctl
      trezord

      bisq-desktop

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
