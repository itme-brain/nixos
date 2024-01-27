{
  description = "Fully Declarative YOLO";

  inputs =
  {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager= {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
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
        ./sysConfig/desktop
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.mainUser = import ./homeConfig/home.nix;
        }
      ];
    };
  };
}
