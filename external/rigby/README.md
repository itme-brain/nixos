# Rigby Recovery

This directory contains disaster-recovery automation for `rigby`, the Ubuntu
AI rig at `192.168.0.23`.

## Managed State

The playbook restores the validated host and application configuration for:

- Ubuntu `24.04.4`
- AMD ROCm `7.2.4` and `amdgpu-dkms`
- `amdgpu.cwsr_enable=0 pcie_aspm.policy=performance`
- Docker CE and the Compose plugin
- pinned ComfyUI, ROCm PyTorch, and the on-demand ComfyUI service
- a pinned ROCm build of the upstream llama.cpp model router
- the `llama-server.service` layout and encrypted API-key integration
- the exact Qwen3.8-27B primary model, DFlash draft model, router preset, and
  locally tuned chat template
- the pinned `web-search-mcp` Compose deployment with its LFM preprocessing
  sidecar
- required users, groups, permissions, and static networking

The retired vLLM and LibreChat deployment is not restored. A stale
`librechat.service` unit is disabled and removed when present; old home
directories are left untouched so this playbook never deletes user data.

## Reproducible AI Artifacts

The Qwen files are not stored in this Git repository. The managed llama
justfile downloads and verifies these pinned public artifacts during recovery:

- `unsloth/Qwen3.8-27B-GGUF` at revision
  `1cff334a4a228324d4ee1f76d55d372588f0d556`
  - `Qwen3.8-27B-UD-Q4_K_XL.gguf`
  - SHA-256: `bee238bbeb3dc0a34bde4d0dedbaee1f98c009e8bb4226f03070054c12fb1372`
- `incoai/Qwen3.8-27B-DFlash2-GGUF` at revision
  `6cb5872e2cee6b4e780a8414922350be8e42d65c`
  - `Qwen3.8-27B-DFlash2-Q4_K_M.gguf`
  - SHA-256: `18a380efc9b7ed8d88677fc895f5c11ae170653434ee378f7348f715c14d0594`

The live primary model had been renamed locally to `UD-Q4_K_M`, despite its
bytes being the upstream `UD-Q4_K_XL` artifact. The managed justfile verifies
and migrates that legacy filename without downloading a duplicate.

`web-search-mcp` owns its CPU-only LFM sidecar definition and downloads that
model into its Docker volume automatically. Its host-only `.env`, SearXNG
secret, and Crawl4AI token are generated idempotently by the repository's
`just up-lfm` workflow.

The llama API key is sourced from `secrets/system/llama.yaml`. The controller
must be able to run `sudo -n sops` with the repository's configured age key.
The decrypted value is never committed or printed by Ansible.

## Manual Prerequisites

These are intentionally documented rather than automated:

- Install Ubuntu `24.04.4`.
- Update BIOS to the known-good version for the board.
- Verify `Above 4G Decoding`, `SVM`, UEFI boot, and PCIe slot configuration.
- Ensure the host is reachable over SSH as `bryan`.
- Ensure passwordless sudo works for `bryan`.
- Ensure the initial DHCP lease is known so recovery can begin.
- Ensure the controller can decrypt `secrets/system/llama.yaml` with
  `sudo -n sops`.

## Recovery Flow

1. Install Ubuntu manually.
2. Clone this repository onto the operator machine.
3. From the repository root, run `just rigby-check HOST=<rigby-ip>`.
4. Preview with `just rigby-recover-dry-run HOST=<rigby-ip>`.
5. Run `just rigby-recover HOST=<rigby-ip>`.
6. Allow time for the llama.cpp ROCm build, Qwen downloads, and container image
   downloads.
7. Reboot `rigby` and validate:
   - `rocminfo`
   - `rocm-smi`
   - `http://rigby:9331/health`
   - `http://rigby:8002/ready`
   - ComfyUI startup on demand

Static netplan application is deliberately the final playbook task because it
may interrupt the recovery SSH connection when the address changes.

## Data Outside Recovery

- ComfyUI models, LoRAs, VAEs, inputs, outputs, workflows, and most custom-node
  state are not downloaded by this playbook.
- Optional llama presets documented but disabled in `models.ini` (LFM2.5 and
  Muse-Glimmer) require their own weights. Only Qwen3.8-27B is guaranteed after
  recovery.
- Docker cache and search-index volumes are recreatable and are not backed up.
- BIOS configuration and physical hardware setup remain manual.
