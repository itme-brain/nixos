{ pkgs, lib, config, ... }:

{
  home.packages = with pkgs; [
    trezor-suite
    trezorctl
    trezord

    electrum
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
}
