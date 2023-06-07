{
  description = "Fully Declarative YOLO";

  inputs =
  {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, disko, nur }:
  let
    system = "x86_64-linux";
    overlays = [
      (final: prev: {
        nur = import nur {
          inherit (prev) pkgs;
          nurpkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
      })
    ];
    pkgs = import nixpkgs {
      inherit system overlays;
      config = {
        allowUnfree = true;
      };
    };
  in
  {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules = [
        ./sysConfig/desktop
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.bryan = import ./homeConfig/home.nix;
        }
      ];
    };
  };
}
