# Crawl4AI runtime image on rigby

The pinned Crawl4AI 0.9.2 image retains its Python packages and browsers.
Its Playwright and Patchright driver executables both use Node 24.22.1 from
the digest-pinned official Debian Bookworm image.

Keep these deployment files in `/home/llama/deployment/crawl4ai`, outside
the upstream web-search-mcp checkout. Build the local image with:

```sh
docker build -t crawl4ai-local:0.9.2-node24.22.1 /home/llama/deployment/crawl4ai
```

Install `node-runtime.conf` as
`/etc/systemd/system/web-search-mcp.service.d/zz-node-runtime.conf` and reload
systemd. The drop-in adds the runtime Compose override after the existing
deployment and private-CA override, preserving the LFM profile and all
existing credentials, networking and volumes. The image must be built locally
before starting the service.

To replace only the crawler while the stack is running, use the same three
Compose files with `up -d --no-deps --no-build --pull never crawl4ai` from
`/home/llama/web-search-mcp`. Verify both browser drivers, container health,
and an authenticated crawl after replacement.
