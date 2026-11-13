# Rigby Recovery

The recovery playbook recreates Rigby's AI services on Ubuntu 26.04 LTS
(amd64). The source revisions and model checksum are recorded in
`playbooks/vars/main.yml`. The deployment configuration was captured from
Rigby on 2026-11-13.

## Managed configuration

- Ubuntu generic kernel and headers from the current 26.04 repositories.
  The captured system uses kernel `7.0.0-43-generic`.
- AMD 31.60 DKMS driver, 26.14 graphics libraries, and ROCm 10.1 for gfx1201.
- GPU overdrive enabled, runtime suspend disabled, and all R9700s capped at
  210 W with a −75 mV voltage offset.
- Radiance v1.17.0, built with ROCm clang and FFmpeg, serving Qwen3.8 Flash Next
  on three GPUs at `127.0.0.1:9332`. The unit retains the live TP3, placement,
  context, KV-cache, speculative decoding, and sampling settings.
- LibreChat, MongoDB, Authentik OIDC login, file uploads, MCP integration, and
  the configured Radiance endpoint. Artifact generation is disabled.
- Web-search MCP, its CPU LFM sidecar, SearXNG, Crawl4AI, Valkey, and the
  five-minute Valkey snapshot timer.
- The authenticated MCP proxy on port 8002 and LibreChat/inference gateway on
  port 9331, including the existing restrictions on direct browser access.
- Host/container CA policy, Docker CE, application users, permissions,
  systemd startup, and static networking.

The existing NixOS server at `192.168.0.154` supplies the public reverse proxy
and Authentik. Its database, OIDC application, certificates and whitelist are
separate from Rigby recovery and must remain available.

## Secrets

The controller reads the existing SOPS files with `sudo -n sops`:

- `secrets/system/llama.yaml`: the shared inference and MCP API key.
- `secrets/system/authentik.env`: `LIBRECHAT_OIDC_SECRET`.

Application environments and the gateway authentication map are rendered from
these values with Ansible logging disabled. There is no host-secret snapshot
or second copy of the shared secrets.

LibreChat session/encryption keys and the search stack's internal tokens are
generated on the recovered host. They persist in owner-only
`/home/librechat/deployment/runtime-secrets.json` and
`/home/llama/deployment/runtime-secrets.json`. Subsequent playbook runs reuse
them. A fresh install starts with fresh sessions.

## Install and recover

1. Install Ubuntu 26.04 LTS, using the usual `bryan` account. Set up SSH access
   and passwordless sudo. BIOS/UEFI configuration remains a manual prerequisite.
2. Clone this repository, including submodules, on the controller. The controller
   needs Ansible and SOPS plus an age identity authorized for both SOPS files.
3. If recovering application data, stage a consistent backup on Rigby before
   running recovery; see the next section.
4. From the repository root, run:

   ```sh
   just rigby-recover HOST=<initial-rigby-ip>
   ```

The playbook installs the kernel/driver and reboots if those settings change,
then builds application images and Radiance, downloads the model, and starts
the services. The model is approximately 122 GB; budget disk space for that,
builds and container images. Static networking is applied last and may move
the SSH endpoint to `192.168.0.23`.

GPU UUIDs default to the three installed cards. For replacement cards, override
`radiance_gpu_ids` with their comma-separated UUIDs. Other deployment overrides
can be passed through `ansible-playbook -e @recovery-overrides.yml` from this
directory. The default reboot behavior is controlled by
`rigby_reboot_after_kernel_install`.

## Persistent data

The playbook restores configuration, not conversation history or uploaded files
from Git. Without a data backup, MongoDB starts empty and users sign in again.
Back up the following separately:

- `/home/librechat/LibreChat/data-node`: MongoDB data, including accounts,
  conversations, agents and settings.
- `/home/librechat/LibreChat/uploads`, `images`, `data`, and `skill`.
- `/home/librechat/deployment/runtime-secrets.json` if retaining encrypted
  credentials stored in the LibreChat database.

Take filesystem backups of MongoDB only while its container is stopped, or use
MongoDB's dump/restore tools. A staged tar archive with paths relative to `/`
can be restored by setting `rigby_data_archive` to its absolute target path.
The playbook stops the LibreChat containers before extracting it and restores
application ownership. Only restore archives you created and trust.

The Qwen model is downloadable from its pinned Hugging Face revision, with the
SHA-256 from the download metadata recorded in the variables file. Restoring
`/home/llama/models/radiance` from backup avoids another download. Search caches
and the CPU sidecar's model volume can be recreated automatically.

## Deployment files

- `radiance/` and `templates/radiance.service.j2`: GPU settings and inference unit.
- `librechat/`: Compose configuration, application config and runtime image builds.
- `web-search/`: Compose overrides, service unit and snapshot timer.
- `gateway/`: both authentication proxies and their gateway unit.
- `templates/`: application environments and host repository/network definitions.
- `security/` and `crawl4ai/`: CA policy and container runtime build inputs.

The MongoDB build includes the exact Brotli package used by the running image,
so recovery does not depend on an artifact remaining in Rigby's apt cache.
