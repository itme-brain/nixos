{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.system.sandpack;
  domain = "ramos.codes";
  privateAccessRules = concatMapStringsSep "\n" (cidr: "allow ${cidr};") config.modules.system.nginx.privateAllowCidrs + "\ndeny all;";

  staticBrowserServer = pkgs.stdenvNoCC.mkDerivation (finalAttrs: let
    pnpm = pkgs.pnpm_10;
  in {
    pname = "static-browser-server";
    version = "1.0.6";

    src = pkgs.fetchFromGitHub {
      owner = "LibreChat-AI";
      repo = "static-browser-server";
      rev = "30de7ae4ebf5433acc0fb640649fb77426a79e04";
      hash = "sha256-OVAGnoh7KRmTPY2bXE0kvCMiPx3tXAooDa8n8ujugYM=";
    };

    patches = [ ./pnpm-lock.patch ];

    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs) pname version src patches;
      pnpm = pnpm;
      fetcherVersion = 3;
      hash = "sha256-+Gz8tQy4rkoi365To9GI6sShPTjuKEmZxtV5mEB2UYk=";
    };

    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.nodejs
      pkgs.pnpmConfigHook
      pnpm
    ];

    buildPhase = ''
      runHook preBuild
      pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/libexec/static-browser-server $out/bin
      cp -r out $out/libexec/

      pnpm exec esbuild \
        ./servers/demo-server.ts \
        --bundle \
        --platform=node \
        --format=cjs \
        --outfile=$out/libexec/static-browser-server/demo-server.js

      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/static-browser-server \
        --add-flags $out/libexec/static-browser-server/demo-server.js

      runHook postInstall
    '';
  });
in
{
  options.modules.system.sandpack = {
    enable = mkEnableOption "Sandpack services";
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers = {
      backend = "podman";
      containers.sandpack-bundler = {
        image = "ghcr.io/librechat-ai/codesandbox-client/bundler:latest";
        ports = [ "127.0.0.1:4333:80" ];
      };
    };

    systemd.services.sandpack-preview = {
      description = "Sandpack static preview server";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${staticBrowserServer}/bin/static-browser-server";
        WorkingDirectory = "${staticBrowserServer}/libexec/static-browser-server";
        Restart = "always";
        RestartSec = 5;
        DynamicUser = true;
        Environment = [
          "HOST=127.0.0.1"
          "PORT=4324"
        ];
      };
    };

    services.nginx.virtualHosts."bundler.${domain}" = {
      useACMEHost = domain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:4333";
        extraConfig = ''
          ${privateAccessRules}

          add_header Access-Control-Allow-Origin "*" always;
          add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
          add_header Access-Control-Allow-Headers "Content-Type, Authorization" always;
          add_header Access-Control-Max-Age "3600" always;

          if ($request_method = OPTIONS) {
            return 204;
          }
        '';
      };
    };

    services.nginx.virtualHosts."preview.${domain}" = {
      useACMEHost = domain;
      forceSSL = true;
      serverAliases = [ "~^.+-preview\\.ramos\\.codes$" ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:4324";
        extraConfig = ''
          ${privateAccessRules}

          add_header Access-Control-Allow-Origin "*" always;
          add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
          add_header Access-Control-Allow-Headers "Content-Type, Authorization" always;
          add_header Access-Control-Max-Age "3600" always;

          if ($request_method = OPTIONS) {
            return 204;
          }
        '';
      };
    };
  };
}
