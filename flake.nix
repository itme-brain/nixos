{
  description = "Modular NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
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
        nixosConfigurations.socrates = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./sysConfig
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
