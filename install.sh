#!/usr/bin/env bash

set -euo pipefail

arg="${1:-nixos}"
isNixOS=$(grep -q 'ID=nixos' /etc/os-release)

case "$arg" in
  "nixos")
    if ! isNixOS; then
      echo "⚠️ - Requires NixOS & sudo priveledge"
    fi
    echo "Install this NixOS Configuration? (y/n)"
    while true; do
      read res;
    if [ "$res" = "y" ] || [ "$res" = "Y" ]; then
      echo "Installing...";
      if [ "$EUID" -ne 0 ]; then
        echo "Allow sudo access? (y/n)"
        while true; do
          read -r res
          case "$res" in
            [yY])
              exec sudo bash "$0" "$@"
              exit 0
              ;;
            [nN])
              echo "Aborting..."
              exit 1
              ;;
            *)
              echo "Please enter a valid response (y/n)"
              ;;
          esac
        done
      fi
      if [ -d "/etc/nixos" ]; then
        echo "The /etc/nixos directory exists."
        echo "Would you like to back up and proceed? (y/n)"
        while true; do
          read -r res
          case "$res" in
            [yY])
              mkdir -p $(git rev-parse --show-toplevel)/bkup
              cp -r /etc/nixos $(git rev-parse --show-toplevel)/bkup.nixos_$(date +%Y%m%d%H%M%S)
              break
              ;;
            [nN])
              echo "Cancelled. Aborting..."
              exit 1
              ;;
            *)
              echo "Error: Please enter a valid response (y/n)"
              ;;
          esac
        done
      else
        ln -s /etc/nixos $(git rev-parse --show-toplevel)
      fi
    fi
elif [ "{{TYPE}}" = "home" ]; then
  echo "Install this Home-Manager Configuration?"
  echo "⚠️ - If you don't have nix + home-manager installed, this will install them both"
  echo "Proceed? (y/n)"
  while true; do
    read -r res
    case "$res" in
      [yY])
        echo "Installing..."

        if grep -q 


        if [ -d "$HOME/.config/home-manager" ]; then
          echo "The ~/.config/home-manager directory exists."
          echo "Would you like to back up and proceed? (y/n)"
          while true; do
            read -r res
            case "$res" in
              [yY])
                mkdir -p $(git rev-parse --show-toplevel)/bkup
                mv $HOME/.config/home-manager $(git rev-parse --show-toplevel)/bkup/home-manager_$(date +%Y%m%d%H%M%S)
                ln -s $HOME/.config/home-manager $(git rev-parse --show-toplevel)
                break
                ;;
              [nN])
                echo "Cancelled. Aborting..."
                exit 1
                ;;
              *)
                echo "Error: Please enter a valid response (y/n)"
                ;;
            esac
          done
        else
          ln -s $HOME/.config/home-manager $(git rev-parse --show-toplevel)
        fi
        ;;
      [nN])
        echo "Cancelled. Aborting..."
        exit 1
        ;;
      *)
        echo "Error: Please enter a valid response (y/n)"
        ;;
    esac
  done
    flake_config="experimental-features = nix-command flakes"

    if [ -f "/etc/nix/nix.conf" ] || [ -f "$HOME/.config/nix/nix.conf" ]; then
      if grep -q "^$flake_config" ""
