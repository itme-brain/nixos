{ description = "Fully Declarative YOLO";

  inputs = 
  { 
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
#      config.packageOverrides = pkgs: {
#        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") 
#        { inherit pkgs; };
#      };
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
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
  { nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./sysConfig/desktop
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.bryan = import ./homeConfig/home.nix { inherit pkgs; };
        }
      ];
    };
  };
}
