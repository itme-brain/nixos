{
  description = "My Nix Configs";

  inputs =
  {
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/2411.6.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, nur, ... }@inputs:
  let
    mkPkgs = system: import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        nvidia.acceptLicense = true;
      };
      overlays = [
        nur.overlays.default
        # Make unstable packages available as pkgs.unstable.*
        (final: prev: {
          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        })
      ];
    };

    mkSystem = { path, system ? "x86_64-linux" }:
      let pkgs = mkPkgs system;
      in nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = { inherit inputs; };
        modules = [
          inputs.sops-nix.nixosModules.sops
          path
        ];
      };

  in
  {
    nixosConfigurations = {
      desktop = mkSystem { path = ./system/machines/desktop; };
      server  = mkSystem { path = ./system/machines/server; };
      wsl     = mkSystem { path = ./system/machines/wsl; };
    };

    devShells.x86_64-linux.default = with mkPkgs "x86_64-linux"; mkShell {
      name = "devShell";
      packages = [
        just
        age
        sops
      ];
    };
  };
}
