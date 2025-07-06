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
        "cln" = {
          home = "/var/lib/lightningd";
          description = "Core Lightning system user";
          isSystemUser = true;
          group = "btc";
          createHome = true;
        };
      };
      groups = {
        "btc" = {
          members = [
            "cln"
          ];
        };
      };
    };

    programs.bash.shellAliases = {
      cln = "lightningd";
    };

    systemd.services.lightningd = {
      description = "Core Lightning Daemon";
      serviceConfig = {
        User = "cln";
        Group = "btc";

        StateDirectory = "lightningd";
        WorkingDirectory = "%S/lightningd";

        ExecStart = "${pkgs.clightning}/bin/lightningd --conf=${clnConfig}";

        Type = "simple";
        KillMode = "process";
        TimeoutSec = 60;
        Restart = "always";
        RestartSec = 2;
      };

      after = [
        "bitcoind-btc.service"
        "network.target"
      ];
      requires = [ "bitcoind-btc.service" ];
      partOf = [ "bitcoind-btc.service" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
