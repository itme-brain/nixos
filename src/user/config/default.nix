{ lib, pkgs, config, ... }:

with lib;
let
  modules = config.modules.user;

in
{
  options = {
    user = mkOption {
      description = "User Configurations";
      type = types.attrs;
      default = with pkgs; rec {
        name = "bryan";
        email = "bryan@ramos.codes";
        shell = bash;
        keys = import ./keys;

        groups = [ "wheel" "networkmanager" "home-manager" "input" ];
        bookmarks = import ./bookmarks;
      };
    };
  };
}
