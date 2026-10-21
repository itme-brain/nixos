{ config, pkgs, ... }:
let
  bundle = config.security.pki.caBundle;
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
  # Match the emergency NixOS distrust policy, including the AAA cross-sign.
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
    "emSign ECC Root CA - G3"
    "emSign Root CA - C1"
    "emSign ECC Root CA - C3"
  ];

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
