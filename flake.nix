{
  description = "Fully Declarative YOLO";

  inputs =
  {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager= {
      url = "github:nix-community/home-manager";
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
    myTerminal = pkgs.callPackage ./terminal/shell.nix { };

  in
  {
    nixosConfigurations.socrates = nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [
        ./sysConfig/desktop
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.bryan = import ./homeConfig/home.nix;
        }
      ];
    };

    defaultPackage.x86_64-linux = myTerminal;
  };
}
