# Run a dry-build
test TYPE="nix" SYSTEM="":
  @if [ "{{TYPE}}" = "home" ]; then \
    if [ -n "{{SYSTEM}}" ]; then \
      echo "Error: Undefined argument"; \
      exit 1; \
    fi; \
    echo "Testing home configuration..."; \
    nix build --dry-run .#homeConfigurations."workstation".config.system.build.toplevel -L; \
  elif [ "{{TYPE}}" = "nix" ]; then \
    if [ -z "{{SYSTEM}}" ]; then \
      SYSTEM="desktop"; \
    fi; \
    if [ "{{SYSTEM}}" = "desktop" ] || [ "{{SYSTEM}}" = "server" ] || [ "{{SYSTEM}}" = "wsl" ] || [ "{{SYSTEM}}" = "laptop" ]; then \
      echo "Testing NixOS configuration for {{SYSTEM}}..."; \
      nix build --dry-run .#nixosConfigurations."{{SYSTEM}}".config.system.build.toplevel -L; \
    else \
      echo "Error: Unknown argument - '{{SYSTEM}}'"; \
      echo "Use one of:"; \
      echo "  desktop"; \
      echo "  server"; \
      echo "  laptop"; \
      echo "  wsl"; \
      exit 1; \
    fi; \
  else \
    echo "Invalid usage: {{TYPE}}. Use 'home' or 'nix'."; \
    exit 1; \
  fi

# Install this repo
install TYPE="nixos":
  if [ "${{TYPE}}" = "nixos" ]; then \
    echo "Install this NixOS Configuration? (y/n)" \
    read res; \
    if [ "$res" = "y"] || [ "$res" = "Y"]; then \
      echo "Installing..."; \
      if [ -d "/etc/nixos" ]; then \
        echo "The /etc/nixos directory exists. Would you like to back up and proceed? (y/n)"; \
        read answer; \
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then \
          sudo cp -r /etc/nixos $(git rev-parse --show-toplevel)/nixos.bkup.$(date +%Y%m%d%H%M%S); \
        elif [ "$answer" = "n" ] || [ "$answer" = "N" ]; then \
          echo "Cancelled. Aborting..."; \
          exit 1; \
        else \
          echo "Error: Please enter a valid response (y/n)" \
        fi \
      else \
        sudo ln -s /etc/nixos $(git rev-parse --show-toplevel) \
      fi \
    elif [ "$res" = "n"] || [ "$res" = "N"]; then \
      echo "Cancelled. Aborting..."; \
    else \
      echo "Error: Please enter a valid response (y/n)" \
    fi
  if [ "${{TYPE}}" = "home" ]; then \
    echo "Install this Home-Manager Configuration? (y/n)" \
    read res; \
    if [ "$res" = "y"] || [ "$res" = "Y"]; then \
      echo "Installing..."; \
      if [ -d "~/.config/home-manager" ]; then \
        echo "The ~/.config/home-manager directory exists. Would you like to back up and proceed? (y/n)"; \
        read answer; \
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then \
          sudo cp -r ~/.config/home-manager $(git rev-parse --show-toplevel)/home-manager.bkup.$(date +%Y%m%d%H%M%S); \
        elif [ "$answer" = "n" ] || [ "$answer" = "N" ]; then \
          echo "Cancelled. Aborting..."; \
          exit 1; \
        else \
          echo "Error: Please enter a valid response (y/n)" \
        fi \
      else \
        sudo ln -s ~/.config/home-manager $(git rev-parse --show-toplevel) \
      fi \
    elif [ "$res" = "n"] || [ "$res" = "N"]; then \
      echo "Cancelled. Aborting..."; \
    else \
      echo "Error: Please enter a valid response (y/n)" \
    fi
  fi
