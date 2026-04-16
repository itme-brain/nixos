# Rigby Recovery

This directory contains disaster-recovery automation for `rigby`, the Ubuntu
AI rig at `192.168.0.23`.

## Scope

This automation manages the host state after a manual Ubuntu install.

It is intended to restore the working state we validated for:

- AMD ROCm `7.2.1`
- `amdgpu-dkms`
- `amdgpu.cwsr_enable=0`
- pinned ComfyUI checkout
- `uv`-managed Python `3.13` venv
- ROCm PyTorch
- ComfyUI service layout
- output sharing over Samba
- required groups and permissions

## Manual Prerequisites

These are intentionally documented, not automated:

- Install Ubuntu `24.04.4`
- Update BIOS to the known-good version for the board
- Verify BIOS settings:
  - `Above 4G Decoding = Enabled`
  - `SVM = Enabled`
  - UEFI boot
  - sane PCIe slot configuration
- Ensure host SSH is reachable as `bryan`
- Ensure passwordless sudo works for `bryan`
- Ensure the initial DHCP lease is known so recovery can begin

## Recovery Flow

1. Install Ubuntu manually.
2. Clone this repository onto the operator machine.
3. From the repo root, run `just rigby-check HOST=<rigby-ip>`.
4. Run `just rigby-recover HOST=<rigby-ip>`.
5. Reboot `rigby`.
6. Validate:
   - `rocminfo`
   - `rocm-smi`
   - ComfyUI startup

## Notes

- The AMD repo and package installs are automated here, but BIOS and physical
  host setup remain manual.
- ComfyUI itself is deployed as an application under `/home/comfy/ComfyUI`.
- The `comfyui.service` unit is installed but left disabled so the service is
  started on demand.
- Models, LoRAs, VAEs, outputs, and other AI assets are not restored by this
  automation. `rigby` is the source of truth for that data, so disaster
  recovery for models requires a separate backup strategy.
- The `just` entrypoints accept `HOST=<ip>` so recovery does not depend on a
  fixed DHCP lease.
- Recovery installs the configured SSH key for `bryan`.
- Static IP configuration is applied at the end of the playbook via netplan.
  The SSH session used for recovery may be interrupted once the new address is
  applied, and subsequent access should use the final static IP.
