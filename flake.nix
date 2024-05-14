{
  description = "My Nix Configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/2311.5.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, disko }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };

  in
  with pkgs;
  {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./src/system/machines/desktop
          home-manager.nixosModules.home-manager
            (import ./src/system/machines/desktop/modules/home-manager)
          #disko.nixosModules.disko
          #  (import ./src/system/machines/desktop/modules/disko)
        ];
      };

      server = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./src/system/machines/server
          home-manager.nixosModules.home-manager
            (import ./src/system/machines/server/modules/home-manager)
        ];
      };

      wsl = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./src/system/machines/wsl
          nixos-wsl.nixosModules.wsl
            (import ./src/system/machines/wsl/wsl.nix)
          home-manager.nixosModules.home-manager
            (import ./src/system/machines/wsl/home.nix)
        ];
      };

      vm = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./src/system/machines/vm
          home-manager.nixosModules.home-manager
            (import ./src/system/machines/vm/modules/home-manager)
          disko.nixosModules.disko
            (import ./src/system/machines/vm/modules/disko)
        ];
      };
    };

    homeConfigurations."work" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./src/system/machines/workstation
      ];
    };

    devShells.${system}.default = callPackage ./shell.nix {};
  };
}
