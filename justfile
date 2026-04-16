SYSTEM := "$(echo $HOSTNAME)"
VALID_SYSTEMS := "desktop server wsl"
RIGBY_DIR := "external/rigby"
RIGBY_HOST := "192.168.0.23"

# Print this list
default:
  @just --list

# Verify SSH connectivity and Ansible access to the Ubuntu AI rig.
[group('rigby')]
rigby-check HOST=RIGBY_HOST:
  @cd {{RIGBY_DIR}} && ansible -i "{{HOST}}," all -u bryan -m ping

# Apply the disaster-recovery playbook for the Ubuntu AI rig.
[group('rigby')]
rigby-recover HOST=RIGBY_HOST:
  @cd {{RIGBY_DIR}} && ansible-playbook -i "{{HOST}}," -u bryan playbooks/recover.yml

# Preview rig recovery changes without modifying the target host.
[group('rigby')]
rigby-recover-dry-run HOST=RIGBY_HOST:
  @cd {{RIGBY_DIR}} && ansible-playbook -i "{{HOST}}," -u bryan playbooks/recover.yml --check --diff

# Validate system argument
[private]
_validate SYSTEM:
  #!/usr/bin/env bash
  case "{{SYSTEM}}" in
    desktop|server|wsl) ;;
    *) echo "Error: Unknown system '{{SYSTEM}}'. Use one of: {{VALID_SYSTEMS}}"; exit 1 ;;
  esac

# Helper to parse submodules from .gitmodules
[private]
_subs_init := '''
  declare -A SUBS
  while read -r key path; do
    name="${key#submodule.}"; name="${name%.path}"
    SUBS[$name]="$path"
  done < <(git config -f .gitmodules --get-regexp 'submodule\..*\.path')
'''

# Clean up build artifacts
[group('nix')]
clean:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Cleaning build artifacts"
  rm -f result
  rm -f ./*.qcow2
  echo "Done"

# Output what derivations will be built
[group('nix')]
out SYSTEM="desktop": (_validate SYSTEM)
  @echo "Outputting derivations to be built for {{SYSTEM}}..."
  @nix build --dry-run .#nixosConfigurations."{{SYSTEM}}".config.system.build.toplevel -L

# Test switch into the next generation
[group('nixos')]
test SYSTEM=SYSTEM: (_validate SYSTEM)
  @echo "Testing switching to next NixOS generation for {{SYSTEM}}..."
  @sudo nixos-rebuild test --flake .#{{SYSTEM}}

# Build the nix expression and hydrate the results directory
[group('nix')]
build SYSTEM="desktop": (_validate SYSTEM)
  @echo "Building NixOS configuration for {{SYSTEM}}..."
  @nix build .#nixosConfigurations."{{SYSTEM}}".config.system.build.toplevel -L
  @echo -e "\033[32mBuild success - result directory hydrated\033[0m"

# Deploy a vm of the defined system
[group('nixos')]
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
[group('nix')]
search PKG:
  nix search nixpkgs {{PKG}}

# Open nixos packages in the browser
[group('nix')]
pkgs:
  @xdg-open https://search.nixos.org/packages

# Open nixos options in the browser
[group('nix')]
options:
  @xdg-open https://search.nixos.org/options

# NixOS-rebuild switch for the current system
[group('nixos')]
switch:
  @echo -e "\033[32m->> Switching to next generation ->>\033[0m"
  @sudo nixos-rebuild switch --flake .#{{SYSTEM}}

# Rollback to previous generation
[group('nixos')]
rollback:
  @sudo nixos-rebuild switch --rollback

# NixOS-rebuild boot for the current system
[group('nixos')]
boot:
  @echo -e "\033[34m->> Reboot to new generation ->>\033[0m"
  @sudo nixos-rebuild boot --flake .#{{SYSTEM}}

# Partition disk only (interactive disk selection)
[group('nixos')]
partition SYSTEM:
  #!/usr/bin/env bash
  set -euo pipefail

  DISKO_CONFIG="./system/machines/{{SYSTEM}}/modules/disko/default.nix"

  if [[ ! -f "$DISKO_CONFIG" ]]; then
    echo "Error: No disko config for '{{SYSTEM}}'"
    exit 1
  fi

  # Build array of disk options with readable info
  declare -a DISK_IDS
  declare -a DISK_OPTIONS

  for id in /dev/disk/by-id/*; do
    name=$(basename "$id")
    [[ "$name" =~ part ]] && continue
    [[ ! "$name" =~ ^(ata|nvme|scsi)- ]] && continue

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

  echo "Writing disk '$DISK' to disko config..."
  sed -i "s|device = \"/dev/disk/by-id/[^\"]*\";|device = \"$DISK\";|" "$DISKO_CONFIG"

  echo "Partitioning $DISK..."
  sudo nix \
    --extra-experimental-features "nix-command flakes" \
    run github:nix-community/disko -- \
    --mode destroy,format,mount \
    "$DISKO_CONFIG"

  echo -e "\033[32mPartitioning complete. Disk mounted at /mnt.\033[0m"

# Install NixOS (partition + install in one shot)
[group('nixos')]
install SYSTEM:
  #!/usr/bin/env bash
  set -euo pipefail

  DISKO_CONFIG="./system/machines/{{SYSTEM}}/modules/disko/default.nix"

  if [[ ! -f "$DISKO_CONFIG" ]]; then
    echo "Error: No disko config for '{{SYSTEM}}'"
    exit 1
  fi

  # Build array of disk options with readable info
  declare -a DISK_IDS
  declare -a DISK_OPTIONS

  for id in /dev/disk/by-id/*; do
    name=$(basename "$id")
    [[ "$name" =~ part ]] && continue
    [[ ! "$name" =~ ^(ata|nvme|scsi)- ]] && continue

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

  echo "Writing disk '$DISK' to disko config..."
  sed -i "s|device = \"/dev/disk/by-id/[^\"]*\";|device = \"$DISK\";|" "$DISKO_CONFIG"

  echo "Partitioning and installing NixOS..."
  sudo nix \
    --extra-experimental-features "nix-command flakes" \
    run github:nix-community/disko/latest#disko-install -- \
    --flake .#{{SYSTEM}} \
    --disk main "$DISK"

  echo -e "\033[32mDone! Reboot to start NixOS.\033[0m"

# Commit all changes and push to upstream
[group('git')]
gh COMMIT_MESSAGE:
  #!/usr/bin/env bash
  set -euo pipefail
  git add -A
  git commit -m "{{COMMIT_MESSAGE}}"
  git push

# Show status of submodules with changes
[group('submodule')]
sstatus:
  #!/usr/bin/env bash
  {{_subs_init}}
  for name in "${!SUBS[@]}"; do
    status=$(git -C "${SUBS[$name]}" status -s)
    [[ -n "$status" ]] && echo -e "\033[34m$name:\033[0m" && echo "$status"
  done

# Pull all submodules and parent
[group('submodule')]
spull:
  #!/usr/bin/env bash
  set -euo pipefail
  {{_subs_init}}
  git pull
  for name in "${!SUBS[@]}"; do
    echo -e "\033[34m$name:\033[0m"
    git -C "${SUBS[$name]}" pull
  done

# Push submodules and parent
[group('submodule')]
spush NAME="":
  #!/usr/bin/env bash
  set -euo pipefail
  {{_subs_init}}
  if [[ -n "{{NAME}}" ]]; then
    path="${SUBS[{{NAME}}]:-}"
    [[ -z "$path" ]] && echo "Unknown: {{NAME}}. Available: ${!SUBS[*]}" && exit 1
    git -C "$path" push
  else
    for path in "${SUBS[@]}"; do git -C "$path" push; done
  fi
  git push

# Commit submodule changes and update parent
[group('submodule')]
scommit NAME="":
  #!/usr/bin/env bash
  set -euo pipefail
  {{_subs_init}}
  MSGS=()

  commit_sub() {
    local name="$1" path="$2"
    [[ -z "$(git -C "$path" status -s)" ]] && return 0
    echo -e "\033[34m$name:\033[0m"
    git -C "$path" status -s
    read -p "Commit message: " MSG
    [[ -z "$MSG" ]] && return 0
    git -C "$path" add -A && git -C "$path" commit -m "$MSG"
    git add "$path"
    MSGS+=("$name: $MSG")
  }

  if [[ -n "{{NAME}}" ]]; then
    path="${SUBS[{{NAME}}]:-}"
    [[ -z "$path" ]] && echo "Unknown: {{NAME}}. Available: ${!SUBS[*]}" && exit 1
    commit_sub "{{NAME}}" "$path"
  else
    for name in "${!SUBS[@]}"; do commit_sub "$name" "${SUBS[$name]}"; done
  fi

  if ! git diff --cached --quiet; then
    COMMIT_MSG="updated submodules"$'\n'
    for m in "${MSGS[@]}"; do COMMIT_MSG+="- $m"$'\n'; done
    git commit -m "$COMMIT_MSG"
  fi

# Commit and push submodules + parent
[group('submodule')]
ssync NAME="":
  #!/usr/bin/env bash
  set -euo pipefail
  {{_subs_init}}
  MSGS=()

  sync_sub() {
    local name="$1" path="$2"
    [[ -z "$(git -C "$path" status -s)" ]] && return 0
    echo -e "\033[34m$name:\033[0m"
    git -C "$path" status -s
    read -p "Commit message: " MSG
    [[ -z "$MSG" ]] && return 0
    git -C "$path" add -A && git -C "$path" commit -m "$MSG"
    git -C "$path" push
    git add "$path"
    MSGS+=("$name: $MSG")
  }

  if [[ -n "{{NAME}}" ]]; then
    path="${SUBS[{{NAME}}]:-}"
    [[ -z "$path" ]] && echo "Unknown: {{NAME}}. Available: ${!SUBS[*]}" && exit 1
    sync_sub "{{NAME}}" "$path"
  else
    for name in "${!SUBS[@]}"; do sync_sub "$name" "${SUBS[$name]}"; done
  fi

  if ! git diff --cached --quiet; then
    COMMIT_MSG="updated submodules"$'\n'
    for m in "${MSGS[@]}"; do COMMIT_MSG+="- $m"$'\n'; done
    git commit -m "$COMMIT_MSG"
  fi
  git push

# Fetch resources and compute sha256 hash
[group('nix')]
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
