# Infrastructure security

This module combines host/container CA policy and temporary runtime fixes.
The stable Nixpkgs pin supplies NGINX 1.30.6 and the four-root CA blacklist
upstream; neither has a local package override or duplicate blacklist.
The container bundle copies NixOS's standard filtered bundle, preserving the
upstream distrust policy. Client environment variables make non-browser clients
use that trust store, including Node's OpenSSL CA mode.

## Temporary releases

The promoted stable and unstable pins still provide Brotli 1.2.0 and curl
8.22.0. The module packages upstream Brotli 1.2.1 and curl/libcurl 8.23.0,
retaining each original curl package's TLS and protocol options. Version guards
stop replacing these packages once the inputs reach the fixed releases.
`system.replaceDependencies` grafts stable/unstable library and curl executable
outputs throughout the system closure, including Immich's native addons.
The desktop also covers 32-bit outputs. ABI and store-name lengths must remain
compatible when changing these releases.

`packages/nodejs-security.nix` separately supplies Node 24.22.1 with its fixed
bundled dependencies. Keep it until the selected upstream Node and all its
shared dependencies are verified fixed. The flake's security overlay also
supplies a replacement helper that rewrites hash-only store references left by
compiler string merging. Retire that helper with the dependency grafts after
confirming no vulnerable library outputs remain in the resulting closure.

## Deployment and verification

Build both configurations normally. Inspect `switch-to-configuration dry-activate`
before a live switch: grafting changes many unit paths and can restart DNS,
networking and graphical services. Stage with
`nix-env -p /nix/var/nix/profiles/system --set SYSTEM_PATH`, followed by
`SYSTEM_PATH/bin/switch-to-configuration boot`.

`scripts/activate-security-units.py` can selectively activate `nginx.service`,
`immich-server.service` and `nix-daemon.service` from the built generation.
Its runtime drop-ins vanish at reboot. Other running processes retain their
loaded libraries until restarted; reboot completes activation. Do not add
these client variables to `systemd.globalEnvironment`, which affects every unit.

`scripts/verify-curl-http2.py NGINX_BINARY CURL_BINARY...` checks concurrent
HTTP/1.1 and HTTP/2 uploads through an isolated local TLS endpoint. Put OpenSSL
on PATH. Check the actual filtered CA bundle and native decoder fixes as well
as service health before retiring temporary overrides. Rigby's separate Ubuntu
and container maintenance is documented in `external/rigby/security/README.md`.
