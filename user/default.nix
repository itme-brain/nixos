{ lib, pkgs, ... }:

with lib;
{
  options = {
    user = mkOption {
      description = "User Configurations";
      type = types.attrs;
      default = with pkgs; rec {
        name = "bryan";
        email = "bryan@ramos.codes";
        shell = bash;
        keys = import ./keys { inherit lib; };

        groups = [ "wheel" "networkmanager" "home-manager" "input" ];
        bookmarks = import ./bookmarks;
      };
    };
  };
}
