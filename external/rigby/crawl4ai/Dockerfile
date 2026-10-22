# TEMPORARY: retire this image, Compose override and zz-node-runtime.conf once
# the official Crawl4AI image ships patched Node in BOTH Playwright and Patchright.
# Verify both browser drivers and an authenticated crawl; retain CA/auth/LFM settings.
FROM node:24.22.1-bookworm-slim@sha256:55fb5f5a527ea2c5c4a95f963e48ef90aa38c7b346054fdc8ee9957a2b55d205 AS runtime

FROM unclecode/crawl4ai:0.9.2@sha256:bd36741e7bdd35ddc1a05d9183e1d6d8cefb61dd640d944a25d026b76e917690
COPY --from=runtime /usr/local/bin/node /usr/local/lib/python3.12/site-packages/playwright/driver/node
COPY --from=runtime /usr/local/bin/node /usr/local/lib/python3.12/site-packages/patchright/driver/node
RUN set -eu; for node in /usr/local/lib/python3.12/site-packages/playwright/driver/node /usr/local/lib/python3.12/site-packages/patchright/driver/node; do \
    "$node" -e 'if (process.version !== "v24.22.1" || typeof require("node:zlib").constants.BROTLI_DECODER_ERROR_FORMAT_BLOCK_SWITCH !== "number") process.exit(1)'; \
    done
