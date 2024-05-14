SYSTEM := "$(echo $HOSTNAME)"

default:
  @just --list

# Output what derivations will be built
test SYSTEM TYPE="nix":
  #!/usr/bin/env bash
  set -euo pipefail
  case "{{TYPE}}" in
    "nixos")
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

# Build the nix expression and hydrate the results directory - pass VM flag to build a VM
build SYSTEM TYPE="nix":
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

search PKG:
  nix search nixpkgs {{PKG}}

pkgs:
  @xdg-open https://search.nixos.org/packages

options:
  @xdg-open https://search.nixos.org/options

# NixOS-rebuild switch short-hand
switch BACK:
  @echo -e "\033[32m->> Switching to next generation ->>\033[0m"
  @sudo nixos-rebuild switch --flake .#{{SYSTEM}}

# NixOS-rebuild boot short-hand
boot:
  @echo -e "\033[34m->> Reboot to new generation ->>\033[0m"
  @echo "Switching to next generation on reboot"
  @sudo nixos-rebuild boot --flake .#{{SYSTEM}}

# Commit all changes and push to upstream
gh MESSAGE:
  #!/usr/bin/env bash
  set -euo pipefail
  git add -A
  git commit -m "{{MESSAGE}}"
  git push
