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
