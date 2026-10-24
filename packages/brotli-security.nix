{ brotli, fetchFromGitHub }:

# Upstream 1.2.1 release, matching nixpkgs PR #577208. Remove when both
# promoted inputs carry the fix; do not replace the bundled Node runtime yet.
brotli.overrideAttrs {
  version = "1.2.1";
  src = fetchFromGitHub {
    owner = "google";
    repo = "brotli";
    tag = "v1.2.1";
    hash = "sha256-llY72cYffDv0ugsH0p89xIPEbElV4L8u7U/Fe8hT3gI=";
  };
}
