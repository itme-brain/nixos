# TEMPORARY: retire this derived image and Compose override once the official
# LibreChat image ships a verified patched runtime. Preserve existing deployment
# settings and validate login, streaming, uploads and MCP before switching back.
FROM node:24.22.1-alpine3.24@sha256:feb76650b7195319268c59cb2d419c732d6c499b13bf5296f16ab59eb1f0a4f3 AS runtime

FROM registry.librechat.ai/librechat-ai/librechat:v0.8.8@sha256:5b706bcee1ca154a1e2987303aaeca0eb27f97919cccee4bb604226c2f8abf61
COPY --from=runtime /usr/local/bin/node /usr/local/bin/node
ENV NODE_VERSION=24.22.1
RUN node -e 'const z = require("node:zlib"); if (process.version !== "v24.22.1" || process.versions.modules !== "137" || typeof z.constants.BROTLI_DECODER_ERROR_FORMAT_BLOCK_SWITCH !== "number") process.exit(1)'
