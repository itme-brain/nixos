{
  description = "My Nix Configs";

  inputs = 
  {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nur = {
      url = "github:nix-community/NUR";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/2411.6.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur, home-manager, nixos-wsl, sops-nix }:
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
          sops-nix.nixosModules.sops
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
    };

    devShells.${system}.default = mkShell {
      name = "devShell";
      packages = [
        just
        age
      ];
    };
  };
}
