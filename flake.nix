{
  description = "Fully Declarative YOLO";

  inputs =
  {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager= {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko }:
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
    nixosConfigurations.socrates = nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [
        ./sysConfig/desktop
        disko.nixosModules.disko
      ];
    };

    homeConfigurations.bryan = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./homeConfig/home.nix
      ];
    };
  };
}
