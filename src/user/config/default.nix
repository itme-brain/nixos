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
        gitConfig = optionalAttrs modules.git.enable {
          userName = "Bryan Ramos";
          userEmail = email;
          signing = optionalAttrs modules.security.gpg.enable {
            key = "F1F3466458452B2DF351F1E864D12BA95ACE1F2D";
            signByDefault = true;
          };
        };
        bookmarks = import ./bookmarks;
      };
    };
  };
}
