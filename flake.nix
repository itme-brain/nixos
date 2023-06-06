{ description = "Fully Declarative YOLO";

  inputs = 
  { 
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
      overlays = [
        (self: super: {
          nur = import (builtins.fetchTarball {
            url = "https://github.com/nix-community/NUR/archive/3a6a6f4da737da41e27922ce2cfacf68a109ebce.tar.gz";
            sha256 = "0g0vxzwm24pvfwhy8f320x030kvacxln6n3b50kwg14cjrirr2yx";
          }) { inherit (super) pkgs; };
        })
      ];
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
