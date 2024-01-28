# My NixOS Configurations ❄️👨‍💻

My modular NixOS🔥

The `user` directory is where you can customize user configurations, the system is configured to grab all attributes defined in here.

The `sysConfig`🖥️ directory contains subdirectories for each of my machines

In the `homeConfig`🏠️ directory, you'll find various dotfiles and config files that make my home directory extra nixy

If you need a list of available packages and options:

- [nixpkgs Packages](https://search.nixos.org/packages) 📦️
- [nixpkgs Options](https://search.nixos.org/options?) 🔍️
- [home-manager Options](https://mipmip.github.io/home-manager-option-search/) ☕️

## Get Inspired 🌟

Ready to go down the Nix 🐇🕳️❓️

Fork this repo and create your own NixOS config✨

Take inspiration💡, borrow ideas💭 and customize it to your 💖 content

⚠️ Be sure to tailor any settings related to my hardware and system to your own hardware⚠️

👉️Run `nixos-generate-config` if you need a new `hardware-configuration.nix`

## Requirements ⚙️

- Nix package manager ❄️
- Nix 2.0 `flakes` enabled⚡️

Install by visiting [nixos.org](https://www.nixos.org/) or through your package manager🚀

### Enabling Flakes ❄️

Unleash Nix💥 

Add to your `nix.conf` or `configuration.nix`👇️

```nix
nix = {
  package = pkgs.nixFlakes;
  extraOptions = "experimental-features = nix-command flakes";
};
```

# Happy Nix Hacking! ❄️🔧💻️❄️
