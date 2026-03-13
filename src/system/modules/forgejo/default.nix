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
        service.REQUIRE_SIGNIN_VIEW = false;
        server = {
          PROTOCOL = "http+unix";
          DOMAIN = "git.ramos.codes";
          HTTP_ADDR = "/run/forgejo/forgejo.sock";
          SSH_DOMAIN = "git.ramos.codes";
          SSH_PORT = 443;
          START_SSH_SERVER = false;
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
