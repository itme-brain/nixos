{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.corn;

in
{ options.modules.corn = { enable = mkEnableOption "corn"; };

  imports = [
    ./core-lightning
    ./sparrow-cli
  ];

  config = mkIf cfg.enable {
    users = {
      users = {
        "bitcoind" = {
          description = "bitcoind system user";
          isSystemUser = true;
          group = "bitcoin";
        };
      };
      groups = {
        "bitcoin" = {
          members = [ "core-lightning" "electrs" ];
        };
      };
    };
    services.bitcoind = {
      "main-net" = {
        enable = true;
        user = "bitcoind";
        group = "bitcoin";
      };
    };
  };
}
