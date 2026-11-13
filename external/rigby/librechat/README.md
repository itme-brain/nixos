# LibreChat on Rigby

`compose.radiance.yaml` runs LibreChat and MongoDB under UID/GID 1004. The
application configuration in `librechat.radiance.yaml` supplies the Radiance
endpoint, web-search MCP and file handling. Artifact generation is disabled.

The recovery playbook installs the files under `/home/librechat/LibreChat`,
renders `.env` from the existing inference/OIDC secrets and local session keys,
and installs `librechat.service` for startup after Docker.

`Dockerfile` builds `librechat-local:v0.8.8-node24.22.1` from pinned upstream
images. `Dockerfile.mongodb` builds `mongo-local:8.0.20-brotli-fixed` using the
included `libbrotli1_1.1.0-2build2+infra1_amd64.deb`. These image selections are
applied by `compose.security.yaml`. The build context and service unit live in
`/home/librechat/deployment`.

Application state is stored in the bind-mounted `data-node`, `uploads`, `logs`,
`images`, `data` and `skill` directories. The recovery README describes which
paths need a separate data backup. The container CA store is mounted from
`/etc/infra-pki/certs`.
