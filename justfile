SYSTEM := "$(echo $HOSTNAME)"
VALID_SYSTEMS := "desktop workstation server wsl vm laptop"

# Print this list
default:
  @just --list

# Validate system argument
[private]
_validate SYSTEM:
  #!/usr/bin/env bash
  case "{{SYSTEM}}" in
    desktop|workstation|server|wsl|vm|laptop) ;;
    *) echo "Error: Unknown system '{{SYSTEM}}'. Use one of: {{VALID_SYSTEMS}}"; exit 1 ;;
  esac

# Clean up build artifacts
clean:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Cleaning build artifacts"
  rm -f result
  rm -f ./*.qcow2
  echo "Done"

# Output what derivations will be built
out SYSTEM="desktop": (_validate SYSTEM)
  @echo "Outputting derivations to be built for {{SYSTEM}}..."
  @nix build --dry-run .#nixosConfigurations."{{SYSTEM}}".config.system.build.toplevel -L

# Test switch into the next generation
test SYSTEM="desktop": (_validate SYSTEM)
  @echo "Testing switching to next NixOS generation for {{SYSTEM}}..."
  @sudo nixos-rebuild test --flake .#{{SYSTEM}}

# Build the nix expression and hydrate the results directory
build SYSTEM="desktop": (_validate SYSTEM)
  @echo "Building NixOS configuration for {{SYSTEM}}..."
  @nix build .#nixosConfigurations."{{SYSTEM}}".config.system.build.toplevel -L
  @echo -e "\033[32mBuild success - result directory hydrated\033[0m"

# Deploy a vm of the defined system
vm SYSTEM: (_validate SYSTEM)
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Building VM for {{SYSTEM}}..."
  nixos-rebuild build-vm --flake .#{{SYSTEM}}
  if [[ -f result/bin/run-{{SYSTEM}}-vm ]]; then
    result/bin/run-{{SYSTEM}}-vm
  else
    echo "Error: VM build failed!"
    exit 1
  fi

# grep nixpkgs for PKG
search PKG:
  nix search nixpkgs {{PKG}}

# Open nixos packages in the browser
pkgs:
  @xdg-open https://search.nixos.org/packages

# Open nixos options in the browser
options:
  @xdg-open https://search.nixos.org/options

# NixOS-rebuild switch for the current system
switch:
  @echo -e "\033[32m->> Switching to next generation ->>\033[0m"
  @sudo nixos-rebuild switch --flake .#{{SYSTEM}}

# Rollback to previous generation
rollback:
  @sudo nixos-rebuild switch --rollback

# NixOS-rebuild boot for the current system
boot:
  @echo -e "\033[34m->> Reboot to new generation ->>\033[0m"
  @sudo nixos-rebuild boot --flake .#{{SYSTEM}}

# Commit all changes and push to upstream
gh COMMIT_MESSAGE:
  #!/usr/bin/env bash
  set -euo pipefail
  git add -A
  git commit -m "{{COMMIT_MESSAGE}}"
  git push

# List available disks for installation
disks:
  @echo "Available disks:"
  @lsblk -d -o NAME,SIZE,MODEL
  @echo ""
  @echo "Disk IDs (use these for install):"
  @ls /dev/disk/by-id/ | grep -E '^(ata|nvme|scsi|usb)' | grep -v 'part' || true

# Install NixOS from live USB (interactive disk selection)
install SYSTEM:
  #!/usr/bin/env bash
  set -euo pipefail

  DISKO_CONFIG="./src/system/machines/{{SYSTEM}}/modules/disko/default.nix"

  if [[ ! -f "$DISKO_CONFIG" ]]; then
    echo "Error: No disko config for '{{SYSTEM}}'"
    echo "Available: desktop, workstation, vm"
    exit 1
  fi

  # Build array of disk options with readable info
  declare -a DISK_IDS
  declare -a DISK_OPTIONS

  for id in /dev/disk/by-id/*; do
    name=$(basename "$id")
    # Skip partitions and non-disk entries
    [[ "$name" =~ part ]] && continue
    [[ ! "$name" =~ ^(ata|nvme|scsi)- ]] && continue

    # Resolve to device and get info
    dev=$(readlink -f "$id")
    dev_name=$(basename "$dev")
    size=$(lsblk -dn -o SIZE "$dev" 2>/dev/null) || continue
    model=$(lsblk -dn -o MODEL "$dev" 2>/dev/null | xargs) || model=""

    DISK_IDS+=("$id")
    DISK_OPTIONS+=("$dev_name  $size  $model")
  done

  if [[ ${#DISK_IDS[@]} -eq 0 ]]; then
    echo "No disks found!"
    exit 1
  fi

  echo "Select a disk:"
  select opt in "${DISK_OPTIONS[@]}"; do
    if [[ -n "$opt" ]]; then
      idx=$((REPLY - 1))
      DISK="${DISK_IDS[$idx]}"
      break
    else
      echo "Invalid selection"
    fi
  done

  echo ""
  echo -e "\033[31m!! WARNING: This will DESTROY all data on $DISK !!\033[0m"
  read -p "Continue? [y/N]: " confirm
  case "${confirm,,}" in
    y|yes) ;;
    *) echo "Aborted."; exit 1 ;;
  esac

  echo "Partitioning $DISK..."
  sudo nix \
    --extra-experimental-features "nix-command flakes" \
    run github:nix-community/disko -- \
    --mode disko \
    --arg disk "\"$DISK\"" \
    "$DISKO_CONFIG"

  echo "Installing NixOS..."
  sudo nixos-install --flake .#{{SYSTEM}} --no-root-passwd

  echo -e "\033[32mDone! Reboot to start NixOS.\033[0m"

# Fetch resources and compute sha256 hash
hash URL:
  #!/usr/bin/env bash
  set -euo pipefail

  if [[ "{{URL}}" =~ \.(tar(\.gz)?|tgz|gz|zip)$ ]]; then
    CONTENTS=$(nix-prefetch-url --unpack {{URL}})
  else
    CONTENTS=$(nix-prefetch-url {{URL}})
  fi

  HASH=$(nix hash convert --hash-algo sha256 "$CONTENTS")

  echo -e "\033[32m$HASH\033[0m"
