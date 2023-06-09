# MyNix ❄️👨‍💻

My personal NixOS stash🔥

The `sysConfig` directory contains subdirectories for each of my machines🖥️

In the `homeConfig`🏠️ directory, you'll find various dotfiles and config files that make my home directory extra nixy

If you need a list of available Nix packages and options:

- [nixpkgs Packages](https://search.nixos.org/packages) 📦️
- [nixpkgs Options](https://search.nixos.org/options?) 🔍️
- [home-manager Options](https://mipmip.github.io/home-manager-option-search/) ☕️

## Get Inspired 🌟

Fork this repo and create your own NixOS config💫

Take inspiration💡, borrow ideas💭 and customize it to your 💖 content

⚠️ Be sure to tailor any settings related to my hardware and system to your own hardware⚠️

👉️Run `nixos-generate-config` if you need a new `hardware-configuration.nix`

## Requirements ⚙️

Get ready to go down the Nix 🐇🕳️, make sure you have the following:

- Nix package manager ❄️
- Nix 2.0 `flakes` enabled⚡️

Install Nix by visiting the [NixOS website](https://www.nixos.org/) or by using your package manager🚀

### Enabling Flakes ❄️

Unlock the full power of Nix, add the following line to your Nix configuration:

```nix
nix = {
  package = pkgs.nixFlakes;
  extraOptions = "experimental-features = nix-command flakes";
};
```

# Happy Nix Hacking! ❄️🔧💻️❄️
