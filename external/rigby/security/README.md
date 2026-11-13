# Rigby application trust and runtime builds

The recovery playbook installs the CA policy from `configure-pki.py` and runs
it before building and starting applications. This provides a shared filtered
bundle under `/etc/infra-pki/certs`, maintains the host distrust policy and
configures the Compose trust mounts and runtime environment.

Ubuntu 26.04 supplies host security updates through its normal repositories.
The kernel and driver installation is handled by `playbooks/tasks/host.yml`.

The deployed container runtime inputs are included in this recovery tree:

- `../librechat/Dockerfile`: LibreChat with Node 24.22.1 from a pinned image.
- `../librechat/Dockerfile.mongodb`: MongoDB 8.0.20 with the included
  `libbrotli1_1.1.0-2build2+infra1_amd64.deb`.
- `../crawl4ai/Dockerfile`: Crawl4AI 0.9.5 with patched Node, Python Brotli,
  system Brotli and Pillow's vendored decoder.
- `brotli-CVE-2026-111497.patch` and `backport-brotli.sh`: the patch and build
  recipe for the Noble library package used inside the MongoDB image. The
  recovery playbook copies the included built package into its build context;
  it does not run this Noble-specific script on the Ubuntu 26.04 host.

The parent recovery README covers application configuration, existing SOPS
secrets and separate persistent-data backups.
