{ lib, pkgs, config, ... }:

let
gpg = config.modules.user.security.gpg;

userConfigs = rec {
  name = "bryan";
  email = "bryan@ramos.codes";
  shell = pkgs.bash;
  nixosDir = /etc/nixos; # PATH to this repo

  # Image name from ~Pictures/wallpapers directory
  wallpaper = "mountains.jpg";

  groups = [ "wheel" "networkmanager" "home-manager" "input" ];

  gitConfig = {
    userName = "Bryan Ramos";
    userEmail = email;
    signing = lib.optionalAttrs gpg.enable {
      key = "F1F3466458452B2DF351F1E864D12BA95ACE1F2D";
      signByDefault = true;
    };
  };

  pgpKey = {
    text = import ./keys/pgpKey.nix;
    trust = 5;
  };

  sshKeys = {
    key1 = import ./keys/sshKey1.nix;
    key2 = import ./keys/sshKey2.nix;
  };
};

in
{
  options = {
    user = lib.mkOption {
      type = lib.types.attrs;
      default = userConfigs;
      description = "User Configurations";
    };
  };
}
