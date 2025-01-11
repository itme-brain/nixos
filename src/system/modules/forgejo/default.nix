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
        "git" = {
          description = "Git server system user";
          isSystemUser = true;
          group = "git";
          extraGroups = mkIf nginx.enable [
            "web"
          ];
        };
        "nginx" = {
          extraGroups = mkIf nginx.enable [
            "git"
          ];
        };
      };
      groups = {
        "git" = {
          members = [
            "git"
          ];
        };
      };
    };

    services.forgejo = rec {
      enable = true;
      user = "git";
      group = "git";
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
