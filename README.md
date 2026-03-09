# My Nix Configurations 💻

My modular Nix configs🔥

## Requirements ⚙️  
- [Nix 2.0 & Flakes enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes_permanently_in_NixOS)

### NixOS Configurations  
- [NixOS](https://www.nixos.org/)  
### Home-Manager Configuration  
- [Nix Home-Manager](https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-standalone)

# Flake End-Points Exposed ❄️  
NixOS Configurations:
  - desktop
  - wsl
  - server (wip)
  - vm

Home-Manager Configurations:
  - workstation

Fork this repo, take inspiration, borrow ideas and create your own NixOS configs & modules

## Developing & Customizing 🔧
If you need a list of available packages and options:
- [nixpkgs Packages](https://search.nixos.org/packages) 📦️
- [nixpkgs Options](https://search.nixos.org/options?) 🔍️
- [Home-Manager Options](https://mipmip.github.io/home-manager-option-search/) ☕️

Invoke `nix develop` to enter a development shell powered by [`just`](https://github.com/casey/just)  
Invoke `just` in order to view an available list of project scripts

`user.configs.nix` is a symlink to conveniently access centrally defined common user variables from the repo root

⚠️ Be sure to tailor any hardware settings to your own
⚠️ Replace the `hardware.nix` found in the `src/system/machines/<machine>` directory
⚠️ Run `nixos-generate-config` to generate a `hardware-configuration.nix` for your current system

## Submodules

This repo uses git submodules for portable cross-platform configurations.

### Neovim Config
The Neovim configuration is a separate repo for portability across non-NixOS systems.

**Location:** `src/user/modules/utils/modules/neovim/config/nvim`
**Repo:** [github.com/itme-brain/nvim](https://github.com/itme-brain/nvim)

#### Cloning with submodules
```bash
git clone --recurse-submodules git@github.com:itme-brain/nixos.git
# Or after cloning:
git submodule update --init
```

#### Updating nvim config
```bash
# Edit files in the submodule, then:
cd src/user/modules/utils/modules/neovim/config/nvim
git add . && git commit -m "your changes" && git push

# Update reference in nixos repo:
git add src/user/modules/utils/modules/neovim/config/nvim
git commit -m "Update nvim submodule" && git push
```

#### Pulling nvim updates from remote
```bash
git submodule update --remote
git add src/user/modules/utils/modules/neovim/config/nvim
git commit -m "Update nvim submodule" && git push
```

#### Standalone nvim install (non-NixOS)
```bash
git clone git@github.com:itme-brain/nvim.git ~/.config/nvim
```

## Directory Structure

```
.
├── flake.nix                          # Flake entrypoint - defines all NixOS configurations
├── flake.lock
├── justfile                           # Project scripts (via `just`)
├── system.configs -> src/system/machines/   # Symlink for quick access
├── user.configs -> src/user/config/         # Symlink for quick access
└── src/
    ├── system/                        # System-level (NixOS) configuration
    │   ├── machines/                  # Per-machine NixOS configurations
    │   │   ├── desktop/               # Desktop config (flake: nixosConfigurations.desktop)
    │   │   │   ├── default.nix        #   Machine entry point
    │   │   │   ├── hardware.nix       #   Machine-specific hardware config
    │   │   │   ├── system.nix         #   System-level settings
    │   │   │   └── modules/
    │   │   │       ├── disko/         #   Disk partitioning (disko)
    │   │   │       └── home-manager/  #   Home-manager integration + home.nix
    │   │   ├── workstation/           # Workstation config (same structure as desktop)
    │   │   ├── server/                # Server config (no disko)
    │   │   ├── vm/                    # VM config
    │   │   ├── wsl/                   # WSL config (includes wsl module)
    │   │   └── laptop/                # Laptop config (stub)
    │   └── modules/                   # Shared system modules (imported by machines)
    │       ├── default.nix
    │       ├── bitcoin/               # Bitcoin node + electrum server
    │       ├── forgejo/               # Self-hosted Forgejo
    │       └── nginx/                 # Nginx reverse proxy
    │
    └── user/                          # User-level (home-manager) configuration
        ├── default.nix                # User module entry point
        ├── config/                    # User identity & settings
        │   ├── default.nix            #   Common user variables (username, email, etc.)
        │   ├── bookmarks/             #   Browser bookmarks
        │   ├── keys/                  #   Public keys
        │   │   ├── pgp/               #     PGP public keys
        │   │   └── ssh/               #     SSH public keys
        │   └── nvim                   #   Symlink to neovim submodule config
        └── modules/                   # Home-manager modules
            ├── bash/                  # Shell config (aliases, prompt, bashrc)
            ├── git/                   # Git config + helper scripts
            ├── tmux/                  # Tmux config
            ├── security/              # Security tools (GPG)
            ├── utils/                 # CLI utilities
            │   └── modules/
            │       ├── dev/           #   Dev tools (penpot, PCB design)
            │       ├── email/         #   Email client (aerc)
            │       ├── irc/           #   IRC client
            │       ├── neovim/        #   Neovim (config is a git submodule)
            │       └── vim/           #   Vim fallback
            └── gui/                   # GUI applications
                ├── modules/
                │   ├── alacritty/     #   Terminal emulator
                │   ├── browsers/      #   Firefox & Chromium
                │   ├── corn/          #   Corn app
                │   ├── fun/           #   Discord, etc.
                │   ├── utils/         #   GUI utilities
                │   └── writing/       #   Writing tools
                └── wm/                # Window managers
                    ├── hyprland/      #   Hyprland (Wayland) + waybar, rofi
                    ├── sway/          #   Sway (Wayland) + rofi
                    ├── i3/            #   i3 (X11) + rofi
                    └── shared/        #   Shared WM config (mimeapps)
```

### How it works

The **flake.nix** is the entrypoint. It defines NixOS configurations (desktop, workstation, server, wsl) that each reference a machine under `src/system/machines/`. Each machine's `default.nix` pulls in its own `hardware.nix`, `system.nix`, and per-machine modules (disko, home-manager).

The **system layer** (`src/system/`) handles NixOS-level concerns: hardware, bootloader, networking, and system services. Shared system-level modules in `src/system/modules/` can be imported by any machine.

The **user layer** (`src/user/`) handles home-manager configuration. `src/user/config/` defines user identity (name, email, keys), while `src/user/modules/` contains modular home-manager configs for individual tools. Each machine's `home-manager/home.nix` selects which user modules to enable.

Root symlinks `system.configs` and `user.configs` provide convenient access to machine definitions and user config from the repo root.
