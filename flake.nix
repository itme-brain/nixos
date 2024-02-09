{
  description = "My NixOS Configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager= {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/2311.5.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };

  in
  {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [
        ./src/systems/desktop
        home-manager.nixosModules.home-manager
          (import ./src/systems/desktop/home.nix)
      ];
    };
    nixosConfigurations.windows = nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [
        ./src/systems/wsl
        nixos-wsl.nixosModules.wsl
          (import ./src/systems/wsl/wsl.nix)
        home-manager.nixosModules.home-manager
          (import ./src/systems/wsl/home.nix)
      ];
    };
  };
}
