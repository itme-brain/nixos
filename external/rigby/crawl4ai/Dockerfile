# TEMPORARY: retire this image, Compose override and zz-security.conf once
# the official image fixes Node, Python Brotli, system Brotli and Pillow's copy.
# Verify both browser drivers and an authenticated crawl; retain CA/auth/LFM settings.
FROM node:24.22.1-bookworm-slim@sha256:55fb5f5a527ea2c5c4a95f963e48ef90aa38c7b346054fdc8ee9957a2b55d205 AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential cmake curl ca-certificates \
    && curl -fLsS https://codeload.github.com/google/brotli/tar.gz/refs/tags/v1.2.1 -o /tmp/brotli.tar.gz \
    && echo '98d35d11a78dc453aebb7d10c3748f3f73ff78c8267c0dc697b8631f67bf7e8f  /tmp/brotli.tar.gz' | sha256sum -c - \
    && tar -xf /tmp/brotli.tar.gz -C /tmp \
    && cmake -S /tmp/brotli-1.2.1 -B /tmp/brotli-build \
      -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/brotli-security -DCMAKE_INSTALL_LIBDIR=lib \
    && cmake --build /tmp/brotli-build --parallel 4 \
    && cmake --install /tmp/brotli-build

FROM unclecode/crawl4ai:0.9.5@sha256:0b05666882bfb67f45d559a5b827839c54127b74aedd723f8ab338a3571b5fc9
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
      libbrotli1=1.0.9-2+deb12u1 patchelf \
    && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --no-cache-dir --no-deps Brotli==1.2.1
COPY --from=runtime /opt/brotli-security/lib/ /opt/brotli-security/lib/
COPY patch-vendored-brotli.py /tmp/patch-vendored-brotli.py
RUN python /tmp/patch-vendored-brotli.py \
    && rm -rf /opt/brotli-security /tmp/patch-vendored-brotli.py
COPY --from=runtime /usr/local/bin/node /usr/local/lib/python3.12/site-packages/playwright/driver/node
COPY --from=runtime /usr/local/bin/node /usr/local/lib/python3.12/site-packages/patchright/driver/node
RUN set -eu; for node in /usr/local/lib/python3.12/site-packages/playwright/driver/node /usr/local/lib/python3.12/site-packages/patchright/driver/node; do \
    "$node" -e 'if (process.version !== "v24.22.1" || typeof require("node:zlib").constants.BROTLI_DECODER_ERROR_FORMAT_BLOCK_SWITCH !== "number") process.exit(1)'; \
    done
USER appuser
