{ pkgs, lib, config, ... }:
let
  fixedBrotli = p: p.callPackage ../../../packages/brotli-security.nix { };
in {
  # ABI-compatible security release. NixOS grafts references throughout the
  # closure, including native addons, without rebuilding the desktop stack.
  # The release/output names have equal length, as required by this mechanism.
  system.replaceDependencies.replacements = map (p: {
    oldDependency = lib.getLib p.brotli;
    newDependency = lib.getLib (fixedBrotli p);
  }) ([ pkgs pkgs.unstable ] ++ lib.optional (config.networking.hostName == "desktop") pkgs.pkgsi686Linux);

  services.nginx.package = pkgs.nginxStable.overrideAttrs {
    version = "1.30.6";
    nginxVersion = "1.30.6";
    src = pkgs.fetchurl {
      url = "https://nginx.org/download/nginx-1.30.6.tar.gz";
      hash = "sha256-PPRvXtdQTUYBJYZre+qZ+zV/MdiH4uY7NVAzEOm4tsg=";
    };
  };
}
