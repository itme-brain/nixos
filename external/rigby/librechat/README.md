# LibreChat runtime image on rigby

This deployment retains the pinned LibreChat v0.8.8 application and replaces
only its Node executable with Node 24.22.1 from the official Alpine 3.24 image.
Both base images are pinned by digest. Application files, npm dependencies,
the frontend, and the existing entrypoint are inherited from LibreChat.

Deployment files live in `/home/librechat/deployment`, outside the upstream
checkout. Build on rigby with:

```sh
docker build -t librechat-local:v0.8.8-node24.22.1 /home/librechat/deployment
```

Install `librechat.service` in `/etc/systemd/system`, reload systemd, and
restart LibreChat after backing up its data and configuration. The service
combines the existing `/home/librechat/LibreChat/compose.radiance.yaml` with
`compose.security.yaml`; the API and MongoDB images and their pull policies change.
The override requires both local images to exist before starting. See
`../security/README.md` for the MongoDB Brotli backport build.

Keep the existing `.env`, credential encryption keys, MongoDB data, uploads,
and other bind mounts. The service retains the existing user, networking,
private CA store, Authentik integration, and boot enablement. When returning
to an upstream image, remove the Compose override from both service commands
and verify that image's runtime before replacing the local image.
