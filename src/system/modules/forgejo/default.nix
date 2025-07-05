{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.forgejo;
  nginx = config.modules.system.nginx;

in
{ options.modules.system.forgejo = { enable = mkEnableOption "Forgejo Server"; };
  config = mkIf cfg.enable {
    users = {
      users = {
        "${config.services.forgejo.user}" = {
          description = "Git server system user";
          isSystemUser = true;
          group = "${config.services.forgejo.user}";
          extraGroups = mkIf nginx.enable [
            "web"
          ];
        };
        "${config.services.nginx.user}" = {
          extraGroups = mkIf nginx.enable [
            "${config.services.forgejo.group}"
          ];
        };
      };
      groups = {
        "${config.services.forgejo.group}" = {
          members = [
            "${config.services.forgejo.user}"
          ];
        };
      };
    };

    services.forgejo = rec {
      enable = true;
      user = "git";
      group = user;
      stateDir = "/var/lib/forgejo";
      
      settings = {
        server = {
          PROTOCOL = "http+unix";
          DOMAIN = "127.0.0.1";
          HTTP_ADDR = "/run/forgejo/forgejo.sock";
        };
      };

      database = {
        inherit user;
        type = "sqlite3";
        path = "${stateDir}/data/forgejo.db";
        createDatabase = true;
      };
    };
  };
}
