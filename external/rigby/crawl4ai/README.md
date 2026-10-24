# Crawl4AI runtime image on rigby

The pinned Crawl4AI 0.9.5 image includes the upstream certificate-verification
and untrusted-config fixes. Insecure TLS is explicitly disabled in Compose.
Its Playwright and Patchright driver executables both use Node 24.22.1 from
the digest-pinned official Debian Bookworm image.

Python Brotli is pinned to 1.2.1 and the system library uses Debian's fixed
1.0.9-2+deb12u1. Pillow's private decoder/common libraries are replaced with
ABI-compatible upstream 1.2.1, preserving its existing image/font features.
The build verifies the fix in all three decoder copies. The final image
continues to run as appuser.

Keep these deployment files in `/home/llama/deployment/crawl4ai`, outside
the upstream web-search-mcp checkout. Build the local image with:

```sh
docker build -t crawl4ai-local:0.9.5-node24.22.1-brotli1.2.1 /home/llama/deployment/crawl4ai
```

Install `security.conf` as
`/etc/systemd/system/web-search-mcp.service.d/zz-security.conf` and reload
systemd. The drop-in adds the runtime Compose override after the existing
deployment and private-CA override, preserving the LFM profile and all
existing credentials, networking and volumes. The image must be built locally
before starting the service.

To replace the crawler and its NGINX authentication gateway, use the same three
Compose files with `up -d --no-deps --no-build --pull never crawl4ai mcp-auth` from
`/home/llama/web-search-mcp`. Verify both browser drivers, container health,
and an authenticated crawl after replacement.

Run `verify-tls.py` inside the container using `docker exec -i crawl4ai python
-u - < verify-tls.py`. It checks actual authenticated API behavior against
valid, self-signed and expired certificate sites, and confirms an API caller
cannot enable insecure TLS against the deployment policy. It prints no tokens
or page contents. The script requires outbound HTTPS access to example.com
and the badssl.com certificate-test hosts.
