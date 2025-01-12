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
    rm ./result
  fi
  if ls *.qcow2 1> /dev/null 2>&1; then
    echo "Removing virtual disks..."
    rm ./*.qcow2
  fi
  echo "Done"

# Output what derivations will be built
out TYPE SYSTEM="desktop":
  #!/usr/bin/env bash
  set -euo pipefail
  case "{{TYPE}}" in
    "nix")
      if
        [ "{{SYSTEM}}" = "desktop" ] || \
        [ "{{SYSTEM}}" = "server" ] || \
        [ "{{SYSTEM}}" = "wsl" ] || \
        [ "{{SYSTEM}}" = "vm" ] || \
        [ "{{SYSTEM}}" = "laptop" ]
      then
        echo "Outputting derivations to be built for NixOS config - {{SYSTEM}}..."
        nix build --dry-run .#nixosConfigurations."{{SYSTEM}}".config.system.build.toplevel -L
        exit 0
      else
        cat <<EOF
  Error: Unknown argument - '{{SYSTEM}}'
  Use one of:
    desktop
    server
    laptop
    vm
    wsl
  EOF
        exit 1
      fi
      ;;
    "home")
      echo "Testing home configuration..."
      nix build --dry-run .#homeConfigurations."workstation".config.home-manager.build.toplevel -L
      exit 0
      ;;
    *)
      cat<<EOF
  Error: Invalid usage: {{TYPE}}
  Use one of:
    nix
    home
  EOF
      exit 1
      ;;
  esac

# Test switch into the next generation
test TYPE SYSTEM="desktop":
  #!/usr/bin/env bash
  set -euo pipefail
  case "{{TYPE}}" in
    "nix")
      if
        [ "{{SYSTEM}}" = "desktop" ] || \
        [ "{{SYSTEM}}" = "server" ] || \
        [ "{{SYSTEM}}" = "wsl" ] || \
        [ "{{SYSTEM}}" = "vm" ] || \
        [ "{{SYSTEM}}" = "laptop" ]
      then
        echo "Testing switching to next NixOS generation for {{SYSTEM}}..."
        sudo nixos-rebuild test --flake .#{{SYSTEM}}
        exit 0
      else
        cat <<EOF
  Error: Unknown argument - '{{SYSTEM}}'
  Use one of:
    desktop
    server
    laptop
    vm
    wsl
  EOF
        exit 1
      fi
      ;;
    "home")
      echo "Testing home configuration..."
      nix build --dry-run .#homeConfigurations."workstation".config.home-manager.build.toplevel -L
      exit 0
      ;;
    *)
      cat<<EOF
  Error: Invalid usage: {{TYPE}}
  Use one of:
    nix
    home
  EOF
      exit 1
      ;;
  esac

# Build the nix expression and hydrate the results directory
build TYPE SYSTEM="desktop":
  #!/usr/bin/env bash
  set -euo pipefail
  case "{{TYPE}}" in
    "nix")
      if
        [ "{{SYSTEM}}" = "desktop" ] || \
        [ "{{SYSTEM}}" = "server" ] || \
        [ "{{SYSTEM}}" = "wsl" ] || \
        [ "{{SYSTEM}}" = "vm" ] || \
        [ "{{SYSTEM}}" = "laptop" ]
      then
        echo "Building resulting NixOS configuration for {{SYSTEM}}..."
        nix build .#nixosConfigurations."{{SYSTEM}}".config.system.build.toplevel -L
        echo -e "\033[34mresult directory hydrated...\033[0m"
        echo -e "\033[32m!! Build success !!\033[0m"
        exit 0
      else
        cat <<EOF
  Error: Unknown argument - '{{SYSTEM}}'
  Use one of:
    desktop
    server
    laptop
    vm
    wsl
  EOF
        exit 1
      fi
      ;;
    "home")
      echo "Hydrating resulting home configuration..."
      nix build --dry-run .#homeConfigurations."workstation".config.home-manager.build.toplevel -L
      exit 0
      ;;
    *)
      cat<<EOF
  Error: Invalid usage: {{TYPE}}
  Use one of:
    nix
    home
  EOF
      exit 1
      ;;
  esac

# Deploy a vm of the defined system
vm SYSTEM:
  #!/usr/bin/env bash
  set -euo pipefail
  if
    [ "{{SYSTEM}}" = "desktop" ] || \
    [ "{{SYSTEM}}" = "server" ] || \
    [ "{{SYSTEM}}" = "wsl" ] || \
    [ "{{SYSTEM}}" = "vm" ] || \
    [ "{{SYSTEM}}" = "laptop" ]
  then
    echo "Building VM for {{SYSTEM}}..."
    nixos-rebuild build-vm --flake .#{{SYSTEM}}

    if [[ -f result/bin/run-{{SYSTEM}}-vm ]]; then
      result/bin/run-{{SYSTEM}}-vm
    else
      echo "Error: VM Build failed!"
      exit 1
    fi
    exit 0
  else
    cat <<EOF
  Error: Unknown argument - '{{SYSTEM}}'
  Use one of:
    desktop
    server
    laptop
    vm
    wsl
  EOF
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
rollback SYSTEM="nixos":
  #!/usr/bin/env bash
  set -euo pipefail
  if [ {{SYSTEM}} = "nixos" ]; then
    sudo nixos-rebuild switch --rollback
  fi

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
