{ config, pkgs, home-manager, ... }:

{
  imports = [ ../../../user ];
  "${config.user.name}" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [ ./home.nix ];
  };
}
