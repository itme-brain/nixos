# October 24 security deployment

These fixes address CVE-2026-111497 and the NGINX advisories fixed by 1.30.6.
Keep the existing CA mounts and Node 24.22.1 overrides. The promoted Nixpkgs
channels and stable LibreChat/Crawl4AI images were still behind on October 24.

## Ubuntu host and MongoDB

Install `backport-brotli.sh` and `brotli-CVE-2026-111497.patch` under
`/usr/local/lib/infra-security`, then run the script as root. It downloads
signed-index Ubuntu Noble source, applies Google's 1.1.x backport
`da9806362874b9bd4b552a3af360b5d6347beb12`, runs the distribution package tests,
and installs `libbrotli1` and `python3-brotli` version
`1.1.0-2build2+infra1`. Binary/source build artifacts remain in
`/var/cache/infra-security`. It does not change the normal APT sources.

Build MongoDB using `../librechat/Dockerfile.mongodb` and the generated
`libbrotli1_1.1.0-2build2+infra1_amd64.deb` together in a build directory:

```sh
docker build -f Dockerfile.mongodb -t mongo-local:8.0.20-brotli-fixed .
```

Install `../librechat/compose.node-runtime.yaml` in
`/home/librechat/deployment`. From `/home/librechat/LibreChat`:

```sh
docker compose -f compose.radiance.yaml -f /home/librechat/deployment/compose.node-runtime.yaml up -d --no-deps --no-build --pull never mongodb
```

Restart `glances`, `radiance`, and `radiance-d1` after updating the host
library, one inference service at a time. Verify both model endpoints return
their expected authenticated response before proceeding.

## Crawl4AI and NGINX gateways

Follow `../crawl4ai/README.md`. Copy its Dockerfile, vendored-library repair
script and Compose override together. The override also pins `mcp-auth` to
the official multi-platform NGINX 1.30.6 image. Pull this image first:

```sh
docker pull nginx@sha256:47928bf67eb62a1863cb08d9ecb52d3e704304ba614eaee17884204677702951
```

Run `update-gateway.py` as root to update the separate gateway's existing
systemd definition without dropping its CA mounts/auth configuration. It
backs up changed unit files under `/var/backups/infra-security-20261024`.
Restart `llama-gateway`. Recreate `crawl4ai` and `mcp-auth` using the existing
three Compose files and `up -d --no-deps --no-build --pull never`.

## Airy

The full `../airy/Dockerfile` now installs Debian's fixed
`libbrotli1=1.1.0-2+deb13u1`. For an incremental deployment of the existing
application, build `../airy/Dockerfile.security` in an otherwise empty
directory, tagging it `clef-airy:ed7cd28-php8.4.27-node24.22.1-brotli-fixed`.
Install the tracked `clef-airy.service`, reload systemd and restart it. Keep
its original image for rollback. No database or storage migration is involved.

## Verification and retirement

Check native and Python decoder fixes by calling `BrotliDecoderErrorString`
with `-17`: the result must end in `BLOCK_SWITCH`. A version number alone
cannot distinguish a distro backport. Check both browser-driver Node binaries,
an authenticated crawl, image/font handling, MongoDB health, LibreChat model
access, Airy, and both NGINX gateways. Do not print tokens or environment values.

Retire the Ubuntu backport and derived MongoDB image once Canonical publishes
and installs a verified fixed package. Its normal newer Ubuntu package version
can supersede the local backport. Remove the remaining image overrides only
after checking every bundled decoder in the replacement image, including
Pillow, Python and both Node drivers. Host package updates do not update
container filesystems.

The crawler's Chrome for Testing 149.0.7827.55 already contains the fixed
`DecodeBlockTypeAndLength` implementation. This was verified against its
exact Chromium tag's `third_party/brotli/dec/decode.c`; an absent error string
in a stripped browser binary alone is not a reliable vulnerability test.
