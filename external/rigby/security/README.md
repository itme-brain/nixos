# Rigby security maintenance

CA policy, Ubuntu backports and container security deployment share this
location. Container image build recipes and service definitions live with
the corresponding applications; host updates do not update container filesystems.

## CA policy

`configure-pki.py` is installed at
`/usr/local/lib/infra-security/configure-pki.py` by `../playbooks/pki.yml`.
It filters the application CA store, repairs private client bundles and configures
container mounts. Keep `/etc/infra-pki/certs` as the persistent mount source.
The CA update hook refreshes this directory when Ubuntu updates its trust store.
Backups remain under `/var/backups/infra-pki`.

## Ubuntu and MongoDB Brotli backport

Install `backport-brotli.sh` and `brotli-CVE-2026-111497.patch` under
`/usr/local/lib/infra-security`, then run the script as root. It downloads
signed-index Ubuntu Noble source, applies Google's 1.1.x backport
`da9806362874b9bd4b552a3af360b5d6347beb12`, runs the distribution package tests,
and installs `libbrotli1` and `python3-brotli` version
`1.1.0-2build2+infra1`. Artifacts remain in `/var/cache/infra-security`.
It does not change the normal APT sources.

Build `../librechat/Dockerfile.mongodb` with the generated
`libbrotli1_1.1.0-2build2+infra1_amd64.deb` in its build directory, tagging
`mongo-local:8.0.20-brotli-fixed`. The LibreChat security Compose override
selects this image. Restart host library consumers after installing a backport,
one inference service at a time, checking authenticated model access.

Retire this backport and derived MongoDB image when Canonical's installed
package is verified fixed. Its newer distribution version can supersede the
local package normally.

## Containers and gateways

- `../crawl4ai/README.md`: Crawl4AI 0.9.5 certificate verification and config
  fixes, Node 24.22.1 drivers and fixed system/Python/Pillow Brotli copies.
  `compose.security.yaml` also selects the official NGINX 1.30.6 image.
- `../librechat/README.md`: pinned LibreChat application with patched Node and
  MongoDB, selected by its security Compose override.
- `../airy/README.md`: canonical full build with PHP 8.4.27, Node 24.22.1
  assets and Debian's corrected Brotli. No incremental security Dockerfile.
- `../gateway/llama-gateway.service`: complete systemd definition for the
  inference/browser gateway, including the pinned official NGINX 1.30.6 image,
  CA mounts and existing authentication configuration. Install it directly
  in `/etc/systemd/system` and reload systemd; no unit-rewriting script.

Pull digest-pinned images and build local images before starting services.
Preserve keys, databases, storage, authentication and CA mounts. Avoid restarting
unrelated inference or database services when changing a single image.

## Verification and retirement

`../crawl4ai/verify-tls.py` checks valid HTTPS and rejection of self-signed,
expired and explicitly bypassed certificates through the authenticated API.
Check both browser-driver Node binaries and native/Python decoders, image/font
handling, MongoDB health, LibreChat, Airy, inference and both NGINX gateways.
Do not print credentials. Decoder error -17 must end in `BLOCK_SWITCH`; version
numbers alone cannot identify distro backports.

Remove custom images only after verifying every bundled decoder and Node
runtime in the replacement. Crawl4AI's Chrome for Testing 149.0.7827.55 was
checked against its exact Chromium tag's Brotli source and already has the fix;
absence of a string in a stripped browser binary alone is not a reliable test.
