{ description = "Modular NixOS Config";

  inputs = 
  { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
      };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nur, disko }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };

    me = "bryan";
    desktop = "socratesV2";

  in    
  { nixosConfigurations.${desktop} = nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules = [
        (import ./sysConfig { inherit me desktop; })
        nur.nixosModules.nur
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager{
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${me} = import ./homeConfig/home.nix { inherit me; };
        }
      ];
    };
  };
}
