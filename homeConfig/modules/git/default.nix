{ lib, pkgs, config, ... }:

with lib;
  let cfg = config.modules.git;
  isBryan = config.user.name == "bryan";

in
{ options.modules.git = { enable = mkEnableOption "git"; };
  config = mkIf cfg.enable {
    programs = {
      git = {
        enable = true;
      } // (lib.optionalAttrs isBryan (import ./config/git.nix));
      gh = {
        enable = true;
        settings.git_protocol = "ssh";
      };
    };

    home.packages = with pkgs; [
      git-crypt
    ];
  };
}
