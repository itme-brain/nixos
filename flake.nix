{
  description = "My Nix Configs";

  inputs = 
  {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nur = {
      url = "github:nix-community/NUR";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/2405.5.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur, home-manager, nixos-wsl, disko }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
      overlays = [
        nur.overlays.default
      ];
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
        ];
      };

      workstation = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./src/system/machines/workstation
          home-manager.nixosModules.home-manager
            (import ./src/system/machines/workstation/modules/home-manager)
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
            (import ./src/system/machines/wsl/modules/wsl)
          home-manager.nixosModules.home-manager
            (import ./src/system/machines/wsl/modules/home-manager)
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

    devShells.${system}.default = mkShell {
      name = "devShell";
      packages = [
        just
      ];
    };
  };
}
