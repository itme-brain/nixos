{
  description = "Modular NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
          inherit pkgs;
          modules = [
            ./machines/hardware-configuration.nix
            ./machines/system.nix
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager{
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.bryan = import ./homeConfig/home.nix;
            }
          ];
        };
      };
}
