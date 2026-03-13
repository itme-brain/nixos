{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.tor;

in
{
  options.modules.system.tor = {
    enable = mkEnableOption "Tor";
  };

  config = mkIf cfg.enable {
    services.tor = {
      enable = true;

      client = {
        enable = true;
        # SOCKS proxy on 127.0.0.1:9050
      };

      settings = {
        ControlPort = 9051;
        CookieAuthentication = true;
        CookieAuthFileGroupReadable = true;
      };
    };
  };
}
