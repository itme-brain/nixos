# NixOS / Home-Manager Flake Configuration

This repository is a stash for my current NixOS and Home-Manager flake setup.

The repository is structured in two main directories: ```homeConfig``` and ```sysConfig```.

The ```homeConfig``` directory contains all the files related to home-manager.
The ```sysConfig``` directory contains a modular NixOS system configuration.


My personal dotfiles are included in the ```homeConfig/dotfiles``` directory.

Feel free to clone/fork and use as you please.


Here are useful resources for finding a list of nix packages and options...

[NixOS](https://search.nixos.org/packages)

[Home-Manager](https://mipmip.github.io/home-manager-option-search/)

## Requirements

 - nix package manager *OR* NixOS
 - Home-Manager
 - Nix 2.0 (flake and nix-command) enabled

Install nix package manager or NixOS here - https://www.nixos.org/ or through your package manager.

If you are on NixOS, nix already comes installed and is the default package manager.

### Enabling Flakes and Nix Commands

First you need to enable the ```flakes``` and ```nix-command``` experimental features.

Add this line anywhere to your nix configuration.

```
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };
```
If you are using nix on a Linux distro, macOS or Windows WSL your config file defaults to
```~/.config/nix/nix.conf```

If you are using NixOS add the code snippet to your system configuration instead, 
located by default in ```/etc/nixos/configuration.nix```

### Home-Manager

> This is a standalone home-manager install, NOT a NixOS/darwin module.

To initialize Home-Manager properly for the first time, run the following command: 

```nix run home-manager/master -- init```

## Contributions

If you find any issues or have any suggestions, 
please feel free to open an issue or submit a pull request!
