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

This repo uses git submodules for portable configurations.

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
cd ~/nixos
git add src/user/modules/utils/modules/neovim/config/nvim
git commit -m "Update nvim submodule" && git push
```

#### Pulling nvim updates from remote
```bash
cd ~/nixos
git submodule update --remote
git add src/user/modules/utils/modules/neovim/config/nvim
git commit -m "Update nvim submodule" && git push
```

#### Standalone nvim install (non-NixOS)
```bash
git clone git@github.com:itme-brain/nvim.git ~/.config/nvim
```
