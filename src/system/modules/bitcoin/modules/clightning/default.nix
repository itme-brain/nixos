{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.modules.system.bitcoin.clightning;
  btc = config.modules.system.bitcoin;

  clnConfig = pkgs.writeTextFile {
    name = "lightning.conf";
    text = builtins.readFile ./config/lightning.conf;
  };

in
{ options.modules.system.bitcoin.clightning = { enable = mkEnableOption "Core Lightning Server"; };
  imports = [ ./plugins ];
  config = mkIf (cfg.enable && btc.enable) {
    #nixpkgs.overlays = [
    #  (final: prev: {
    #    clightning = prev.electrs.overrideAttrs (old: rec {
    #      version = "24.08";
    #      src = pkgs.fetchFromGitHub {
    #        owner = "ElementsProject";
    #        repo = "lightning";
    #        rev = "82f4ad68e34a2428c556e63fc2632d48a914968c";
    #        hash = "sha256-MWU75e55Zt/P4aaIuMte7iRcrFGMw0P81b8VNHQBe2g";
    #      };
    #      cargoDeps = old.cargoDeps.overrideAttrs (lib.const {
    #        name = "lightning-vendor.tar.gz";
    #        inherit src;
    #        outputHash = "sha256-MWU75e55Zt/P4aaIuMte7iRcrFGMw0P81b8VNHQBe2g=";
    #      });
    #    });
    #  })
    #];

    environment.systemPackages = with pkgs; [
      clightning
    ];

    users = {
      users = {
        "clightning" = {
          home = "/var/lib/clightning";
          description = "Core Lightning system user";
          isSystemUser = true;
          group = "bitcoin";
          createHome = true;
        };
      };
      groups = {
        "bitcoin" = {
          members = mkAfter [
            "clightning"
          ];
        };
      };
    };

    programs.bash.shellAliases = {
      cln = "lightningd";
    };

    systemd.services.lightningd = {
      description = "Core Lightning Daemon";

      script = "${pkgs.clightning}/bin/lightningd";
      scriptArgs = ''
        --conf=${clnConfig}
      '';

      after = [
        "bitcoind-btc.service"
      ];

      serviceConfig = {

        User = "clightning";
        Group = "bitcoin";

        Type = "simple";
        KillMode = "process";
        TimeoutSec = 60;
        Restart = "always";
        RestartSec = 60;
      };
      requisite = [
        "bitcoind-btc.service"
        "network.target"
      ];
    };

    networking.firewall.allowedTCPPorts = [ 9735 ];
  };
}
