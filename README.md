# My Nix Configurations 💻

My modular Nix configs 🔥

## Requirements ⚙️

- [Nix 2.0 & Flakes enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes_permanently_in_NixOS)
- [NixOS](https://www.nixos.org/) for system configurations
- [Nix Home-Manager](https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-standalone) for user configurations

## Flake Endpoints ❄️

NixOS Configurations: `desktop` · `workstation` · `server` (wip) · `vm` · `wsl`

## Fresh Install 🚀

From the NixOS live installer:

```bash
# Enable flakes (not enabled by default on installer)
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf

# Clone repo
nix run nixpkgs#git -- clone --recurse-submodules https://github.com/itme-brain/nixos.git
cd nixos

# Enter dev shell and install
nix develop
just install desktop
```

Replace `desktop` with `workstation` or `vm` as needed.

## Getting Started 🔧

```bash
git clone --recurse-submodules git@github.com:itme-brain/nixos.git
```

Enter the dev shell with `nix develop`, then run `just` to see available project scripts.

Useful resources:
- [nixpkgs Packages](https://search.nixos.org/packages) 📦️
- [nixpkgs Options](https://search.nixos.org/options?) 🔍️
- [Home-Manager Options](https://mipmip.github.io/home-manager-option-search/) ☕️

⚠️ Be sure to tailor any hardware settings to your own — replace the `hardware.nix` in `src/system/machines/<machine>` with output from `nixos-generate-config`

## Submodules 🔗

Standalone portable configurations maintained as separate repos. Each can be cloned independently on any system — NixOS or not.

| Submodule | Purpose | Repo | Standalone Install |
|-----------|---------|------|--------------------|
| **nvim** | Full IDE (LSP, treesitter, telescope) | [itme-brain/nvim](https://github.com/itme-brain/nvim) | `git clone git@github.com:itme-brain/nvim.git ~/.config/nvim` |
| **vim** | Lightweight editor for headless servers | [itme-brain/vim](https://github.com/itme-brain/vim) | `git clone git@github.com:itme-brain/vim.git ~/.vim` |

```bash
# Update a submodule
cd <submodule-path>
git add . && git commit -m "your changes" && git push
cd /path/to/nixos
git add <submodule-path> && git commit -m "Update <name> submodule"

# Pull submodule updates from remote
git submodule update --remote
git add <submodule-path> && git commit -m "Update <name> submodule"
```

## Directory Structure 🗂️

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
        │   ├── nvim                   #   Symlink to neovim submodule config
        │   └── vim                    #   Symlink to vim submodule config
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
            │       └── vim/           #   Vim lightweight (config is a git submodule)
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

**flake.nix** defines NixOS configurations (desktop, workstation, server, wsl) that each reference a machine under `src/system/machines/`. Each machine's `default.nix` pulls in its own `hardware.nix`, `system.nix`, and per-machine modules (disko, home-manager).

The **system layer** (`src/system/`) handles NixOS-level concerns: hardware, bootloader, networking, and system services. Shared modules in `src/system/modules/` can be imported by any machine.

The **user layer** (`src/user/`) handles home-manager configuration. `src/user/config/` defines user identity (name, email, keys), while `src/user/modules/` contains modular home-manager configs for individual tools. Each machine's `home-manager/home.nix` selects which user modules to enable.

Root symlinks `system.configs` and `user.configs` provide quick access to machine definitions and user config from the repo root.
