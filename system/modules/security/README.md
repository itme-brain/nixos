# Infrastructure security

This module keeps host and container clients on the NixOS CA trust policy.
NGINX and the CA distrust policy come from Nixpkgs.
The container bundle copies NixOS's standard filtered bundle, preserving the
upstream distrust policy. Client environment variables make non-browser clients
use that trust store, including Node's OpenSSL CA mode.

## Upstream packages

Package versions are controlled by `flake.lock`. Immich, Pi, and Codex use
`pkgs.unstable` packages.

## Verification

Build configurations normally and inspect their runtime closures when refreshing
the inputs. Check that no older Brotli/curl or affected Node outputs return.
Running processes retain their loaded libraries until restarted or rebooted.

Rigby's separate Ubuntu and container maintenance is documented in
`external/rigby/security/README.md`.
