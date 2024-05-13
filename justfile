default:
  @just --list

# Output what derivations will be built
test TYPE="nix" SYSTEM="desktop":
  #!/usr/bin/env bash
  set -euo pipefail
  case "{{TYPE}}" in
    "nix")
      if [ "{{SYSTEM}}" = "desktop" ] || [ "{{SYSTEM}}" = "server" ] || [ "{{SYSTEM}}" = "wsl" ] || [ "{{SYSTEM}}" = "laptop" ]; then
        echo "Testing NixOS configuration for {{SYSTEM}}..."
        nix build --dry-run .#nixosConfigurations."{{SYSTEM}}".config.system.build.toplevel -L
        exit 0
      else
        echo "Error: Unknown argument - '{{SYSTEM}}'"
        echo "Use one of:"
        echo "  desktop"
        echo "  server"
        echo "  laptop"
        echo "  wsl"
        exit 1
      fi
      ;;
    "home")
      echo "Testing home configuration..."
      nix build --dry-run .#homeConfigurations."workstation".config.home-manager.build.toplevel -L
      exit 0
      ;;
    *)
      echo "Invalid usage: {{TYPE}}.";
      echo "Use one of:"
      echo "  nixos"
      echo "  home"
      exit 1
      ;;
  esac

# Build the nix expression and hydrate the results directory
build TYPE="nix" SYSTEM="desktop":
  #!/usr/bin/env bash
  set -euo pipefail
  case "{{TYPE}}" in
    "nix")
      if [ "{{SYSTEM}}" = "desktop" ] || [ "{{SYSTEM}}" = "server" ] || [ "{{SYSTEM}}" = "wsl" ] || [ "{{SYSTEM}}" = "laptop" ]; then
        echo "Hydrating resulting NixOS configuration for {{SYSTEM}}..."
        nix build .#nixosConfigurations."{{SYSTEM}}".config.system.build.toplevel -L
        exit 0
      else
        echo "Error: Unknown argument - '{{SYSTEM}}'"
        echo "Use one of:"
        echo "  desktop"
        echo "  server"
        echo "  laptop"
        echo "  wsl"
        exit 1
      fi
      ;;
    "home")
      echo "Hydrating resulting home configuration..."
      nix build --dry-run .#homeConfigurations."workstation".config.home-manager.build.toplevel -L
      exit 0
      ;;
    *)
      echo "Invalid usage: {{TYPE}}.";
      echo "Use one of:"
      echo "  nixos"
      echo "  home"
      exit 1
      ;;
  esac

# NixOS-rebuild switch short-hand
up SYSTEM="desktop":
  @echo "Switching to next generation"
  sudo nixos-rebuild switch --flake .#{{SYSTEM}}

# NixOS-rebuild boot short-hand
boot SYSTEM="desktop":
  @echo "Switching to next generation on reboot"
  sudo nixos-rebuild boot --flake .#{{SYSTEM}}

# Commit all changes and push to upstream
gh MESSAGE:
  #!/usr/bin/env bash
  set -euo pipefail
  git add -A
  git commit -m "{{MESSAGE}}"
  git push

#Fetch resources and compute sha256 hash
hash URL:
  #!/usr/bin/env bash
  set -euo pipefail
  if echo "{{URL}}" | grep -E '\.(tar\.gz|tgz|zip)$'; then
    CONTENTS=$(nix-prefetch-url --unpack "{{URL}}")
  else
    CONTENTS=$(nix-prefetch-url "{{URL}}")
  fi
  HASH=$(echo -n "$CONTENTS" | nix hash to-sri --type sha256)
  echo "$HASH"
