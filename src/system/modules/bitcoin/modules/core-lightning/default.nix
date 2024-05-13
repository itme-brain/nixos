{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.modules.system.bitcoin.core-lightning;
  rest = config.modules.system.bitcoin.core-lightning.REST;
  home = /var/lib/clightning;

  btc = config.modules.system.bitcoin;
  conf = pkgs.writeText "lightning.conf" (import ./config { inherit home; });

in
{ options.modules.system.bitcoin.core-lightning = { enable = mkEnableOption "system.bitcoin.core-lightning"; };
  imports = [ ./plugins ];
  config = mkIf (cfg.enable && btc.enable) {
    nixpkgs.overlays = [
      (final: prev: {
        clightning = prev.clightning.overrideAttrs (old: rec {
          version = "24.02.2";
          src = builtins.fetchurl {
            url = ''
              https://github.com/ElementsProject/lightning/releases/download/v${version}/clightning-v${version}.zip
            '';
            sha256 = ''
              sha256-096jlfrda4pq8zwp9iqaq8gnnb8r3vir42vjrfamxd53kdy42aq1
            '';
          };
          buildInputs = with pkgs; old.buildInputs ++
          lib.optionals (rest.enable) [
            nodejs
          ];
          nativeBuildInputs = with pkgs; old.nativeBuildInputs ++
          lib.optionals (rest.enable) [
            makeWrapper
          ];
          postInstall = old.postInstallPhase ++
          lib.optionals (rest.enable) ''
            wrapProgram $out/clrest.js \
              --suffix PATH "${lib.makeBinPath [ nodejs ]}"
          '';
        });
      })
    ];

    environment.systemPackages = with pkgs; [
      clightning
    ];

    users = {
      users = {
        "clightning" = {
          inherit home;
          description = "core-lightning system user";
          isSystemUser = true;
          group = "bitcoin";
          createHome = true;
        };
      };
    };

    systemd.services.lightningd = {
      Unit = {
        Description = "Core Lightning daemon";
        Requires = [ "bitcoind.service" ];
        After = [ "bitcoind.service" "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
        ExecStart = ''
          ${pkgs.clightning}/bin/lightningd \
          --conf=${conf}
          --lightning-dir=${home}
        '';

        RuntimeDirectory = "lightningd";

        User = "clightning";
        Group = "bitcoin";

        Type = "forking";
        PIDFile = "/run/lightningd/lightningd.pid";
        Restart = "on-failute";

        PrivateTmp = true;
        ProtectSystem = "full";
        NoNewPrivileges = true;
        PrivateDevices = true;
        MemoryDenyWriteAccess = false;
      };
      Install = {
        WantedBy = [ "multi-user.target" ];
      };
    };
  };
}
