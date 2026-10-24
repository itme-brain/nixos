{ config, pkgs, lib, ... }:
let
  bundle = config.security.pki.caBundle;
  packageSets = [ pkgs pkgs.unstable ]
    ++ lib.optional (config.networking.hostName == "desktop") pkgs.pkgsi686Linux;

  # Temporary upstream releases until both promoted inputs include the fixes.
  replacementsFor = p:
    let
      brotli = p.brotli.overrideAttrs {
        version = "1.2.1";
        src = p.fetchFromGitHub {
          owner = "google";
          repo = "brotli";
          tag = "v1.2.1";
          hash = "sha256-llY72cYffDv0ugsH0p89xIPEbElV4L8u7U/Fe8hT3gI=";
        };
      };
      curlReplacements = original:
        let fixed = original.overrideAttrs {
          version = "8.23.0";
          src = p.fetchurl {
            url = "https://curl.se/download/curl-8.23.0.tar.xz";
            hash = "sha256-ja3X0lNqMU+YKtBaZRtxP0Jr99Aswsds/7l5byIY5sU=";
          };
        };
        in lib.optionals (lib.versionOlder original.version "8.23.0")
          (map (output: {
            oldDependency = original.${output};
            newDependency = fixed.${output};
          }) [ "out" "bin" ]);
    in lib.optional (lib.versionOlder p.brotli.version "1.2.1") {
      oldDependency = lib.getLib p.brotli;
      newDependency = lib.getLib brotli;
    } ++ lib.concatMap curlReplacements [ p.curl p.curlMinimal ];
  clientEnvironment = {
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    CURL_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    AWS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    PIP_CERT = "/etc/ssl/certs/ca-certificates.crt";
    UV_NATIVE_TLS = "true";
    # Node's embedded Mozilla roots do not consume browser revocations.
    NODE_OPTIONS = "--use-openssl-ca";
  };
in {
  # NGINX and root distrust use the pinned upstream NixOS definitions.
  # Graft ABI-compatible fixes through native addons without a full rebuild.
  system.replaceDependencies.replacements = lib.concatMap replacementsFor packageSets;

  environment.variables = clientEnvironment;
  # Do not change systemd.globalEnvironment: it changes every unit and can
  # stop networking/DNS during a live switch. Scope daemon overrides below.
  nix.envVars = clientEnvironment;

  # Containers cannot follow /etc/ssl symlinks into the host's Nix store.
  system.build.containerCA = pkgs.runCommand "container-ca-certificates" { } ''
    mkdir -p "$out"
    # Use buildcatrust's standard bundle: converting the AUX bundle with
    # OpenSSL would discard distrust attributes and restore rejected roots.
    cp ${builtins.dirOf bundle}/ca-no-trust-rules-bundle.crt "$out/ca-certificates.crt"
    ln -s ca-certificates.crt "$out/ca-bundle.crt"
    ln -s ca-certificates.crt "$out/cert.pem"
  '';
}
