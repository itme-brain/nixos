# Output what derivations will be built
test TYPE="nixos" SYSTEM="desktop":
  #!/usr/bin/env bash
  set -euo pipefail
  if [ "{{TYPE}}" = "home" ]; then
    if [ -n "{{SYSTEM}}" ]; then
      echo "Error: Undefined argument"
      exit 1
    fi
    echo "Testing home configuration..."
    nix build --dry-run .#homeConfigurations."workstation".config.system.build.toplevel -L
  elif [ "{{TYPE}}" = "nixos" ]; then
    if [ "{{SYSTEM}}" = "desktop" ] || [ "{{SYSTEM}}" = "server" ] || [ "{{SYSTEM}}" = "wsl" ] || [ "{{SYSTEM}}" = "laptop" ]; then
      echo "Testing NixOS configuration for {{SYSTEM}}..."
      nix build --dry-run .#nixosConfigurations."{{SYSTEM}}".config.system.build.toplevel -L
    else
      echo "Error: Unknown argument - '{{SYSTEM}}'"
      echo "Use one of:"
      echo "  desktop"
      echo "  server"
      echo "  laptop"
      echo "  wsl"
      exit 1
    fi
  else
    echo "Invalid usage: {{TYPE}}.";
    echo "Use one of:"
    echo "  nixos"
    echo "  home"
    exit 1
  fi

# Symlinks /etc/nixos or ~/.config/home-manager to this repo
install:
  source ./install

# Commit all changes and push to upstream
gh MESSAGE="":
  #!/usr/bin/env bash
  set -euo pipefail
  if [ -n "{{MESSAGE}}" ]; then
    git add -A
    git commit -m "{{MESSAGE}}"
    git push
  else
    echo "Error: Empty commit message"
  fi
