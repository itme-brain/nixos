# NixOS Configuration

Modular NixOS flake configuration with home-manager integration.

## Requirements

- [Nix with Flakes](https://nixos.wiki/wiki/Flakes#Enable_flakes_permanently_in_NixOS)
- [NixOS](https://www.nixos.org/) for system configurations
- [Home-Manager](https://nix-community.github.io/home-manager/) for user configurations

## Flake Outputs

| Configuration | Description |
|---------------|-------------|
| `desktop` | Primary workstation |
| `server` | Home server |
| `wsl` | Windows Subsystem for Linux |

## Fresh Install

From the NixOS live installer:

```bash
# Enable flakes
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf

# Clone repo
nix run nixpkgs#git -- clone --recurse-submodules https://github.com/itme-brain/nixos.git
cd nixos

# Enter dev shell and install
nix develop
just install desktop
```

## Getting Started

```bash
git clone --recurse-submodules git@github.com:itme-brain/nixos.git
cd nixos
nix develop
just
```

**Note:** Replace `hardware.nix` in `system/machines/<machine>` with output from `nixos-generate-config` for your hardware.

## Directory Structure

```
.
├── flake.nix
├── flake.lock
├── justfile
│
├── system/
│   ├── keys/                      # Machine SSH keys
│   │   └── desktop/
│   └── machines/
│       ├── desktop/
│       │   ├── default.nix        # Machine entry point
│       │   ├── hardware.nix       # Hardware config
│       │   ├── system.nix         # System settings
│       │   └── modules/
│       │       ├── disko/         # Disk partitioning
│       │       └── home-manager/  # Home-manager integration
│       ├── server/                # Server (same structure)
│       └── wsl/                   # WSL (same structure)
│
└── user/
    ├── default.nix                # User options (name, email, keys)
    ├── home.nix                   # Shared home-manager defaults
    ├── bookmarks/
    ├── keys/
    │   ├── age/
    │   ├── pgp/
    │   └── ssh/
    └── modules/
        ├── bash/bash/             # Shell (submodule)
        ├── git/git/               # Git (submodule)
        ├── neovim/nvim/           # Neovim (submodule)
        ├── vim/vim/               # Vim (submodule)
        ├── tmux/
        ├── dev/                   # CLI dev tools
        ├── security/
        │   ├── gpg/
        │   └── yubikey/
        ├── utils/
        │   ├── dev/               # Dev tools (claude-code, direnv, etc.)
        │   ├── email/
        │   ├── irc/
        │   └── writing/
        └── gui/
            ├── default.nix        # Browser-focused mimeApps
            ├── wm/
            │   ├── hyprland/
            │   └── sway/
            ├── browsers/
            ├── alacritty/
            ├── dev/
            │   ├── pcb/           # Arduino, KiCad
            │   └── design/        # Penpot
            ├── corn/
            ├── fun/
            └── utils/
```

## Architecture

**flake.nix** defines NixOS configurations that reference machines under `system/machines/`.  
Each machine imports its hardware, system settings, and home-manager config.

**user/home.nix** provides shared defaults for all users:  
- Essential packages
- Default modules

**Machine home.nix** imports user defaults and enables machine-specific modules.

## Resources

- [nixpkgs Packages](https://search.nixos.org/packages)
- [nixpkgs Options](https://search.nixos.org/options)
- [Home-Manager Options](https://home-manager-options.extranix.com)
