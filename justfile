SYSTEM := "$(echo $HOSTNAME)"

# Print this list
default:
  @just --list

# Clean up build artifacts
clean:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Cleaning build artifacts"
  if [ -d result ]; then
    echo "Removing result directory..."
    rm ./result;
  fi
  if ls *.qcow2 1> /dev/null 2>&1; then
    echo "Removing virtual disk..."
    rm ./*.qcow2;
  fi
  echo "All clean!"

# Output what derivations will be built
test SYSTEM TYPE="nixos":
  #!/usr/bin/env bash
  set -euo pipefail
  case "{{TYPE}}" in
    "nixos")
      if
        [ "{{SYSTEM}}" = "desktop" ] || \
        [ "{{SYSTEM}}" = "server" ] || \
        [ "{{SYSTEM}}" = "wsl" ] || \
        [ "{{SYSTEM}}" = "vm" ] || \
        [ "{{SYSTEM}}" = "laptop" ]
      then
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
        echo "  vm"
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

# Build the nix expression and hydrate the results directory - pass VM flag to build a VM
make SYSTEM TYPE="nixos":
  #!/usr/bin/env bash
  set -euo pipefail
  case "{{TYPE}}" in
    "nixos")
      if
        [ "{{SYSTEM}}" = "desktop" ] || \
        [ "{{SYSTEM}}" = "server" ] || \
        [ "{{SYSTEM}}" = "wsl" ] || \
        [ "{{SYSTEM}}" = "vm" ] || \
        [ "{{SYSTEM}}" = "laptop" ]
      then
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
        echo "  vm"
        exit 1
      fi
      ;;
    "home")
      echo "Hydrating resulting home configuration..."
      nix build --dry-run .#homeConfigurations."workstation".config.home-manager.build.toplevel -L
      exit 0
      ;;
    "vm")
      if [ "{{SYSTEM}}" = "desktop" ] || [ "{{SYSTEM}}" = "server" ] || [ "{{SYSTEM}}" = "wsl" ] || [ "{{SYSTEM}}" = "laptop" ]; then
        echo "Building VM for {{SYSTEM}}..."
        nixos-rebuild build-vm --flake .#{{SYSTEM}}
        result/bin/run-{{SYSTEM}}-vm
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
    *)
      echo "Invalid usage: {{TYPE}}."
      echo "Use one of:"
      echo "  nixos"
      echo "  home"
      exit 1
      ;;
  esac

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

# NixOS-rebuild boot for the current system
boot:
  @echo -e "\033[34m->> Reboot to new generation ->>\033[0m"
  @echo "Switching to next generation on reboot"
  @sudo nixos-rebuild boot --flake .#{{SYSTEM}}

# Commit all changes and push to upstream
gh COMMIT_MESSAGE:
  #!/usr/bin/env bash
  set -euo pipefail
  git add -A
  git commit -m "{{COMMIT_MESSAGE}}"
  git push

#Fetch resources and compute sha256 hash
hash URL:
  #!/usr/bin/env bash
  set -euo pipefail

  if echo "{{URL}}" | grep -E '\.(tar\.gz|tgz|zip)$'; then
    CONTENTS=$(nix-prefetch-url --unpack {{URL}} | tail -n 1)
  else
    CONTENTS=$(nix-prefetch-url {{URL}} | tail -n 1)
  fi

  HASH=$(nix hash to-sri --type sha256 "$CONTENTS")

  echo -e "\033[32m$HASH\033[0m"
