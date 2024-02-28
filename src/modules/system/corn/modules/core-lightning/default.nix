{ lib, pkgs, config, ... }:

with lib;
  let cfg = config.modules.corn.core-lightning;

in
{ options.modules.corn.core-lightning = { enable = mkEnableOption "corn.core-lightning"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      clightning
    ];

    systemd.services.clightning = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        ${pkgs.clightning}/bin/lightningd --conf=...
      '';
      serviceConfig = {
        User = "core-lighting";
        Group = "bitcoin";
      };
    };
  };
}
