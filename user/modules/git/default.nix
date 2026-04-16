{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.modules.user.git;

in
{ options.modules.user.git = { enable = mkEnableOption "user.git"; };
  config = mkIf cfg.enable {
    programs = {
      git = {
        enable = true;
      };
      gh = {
        enable = true;
        settings.git_protocol = "ssh";
      };
    };

    home = {
      packages = with pkgs; [
        git-crypt
      ];
      file.".config/git" = {
        source = ./git;
        recursive = true;
      };
    };

    programs.bash.initExtra = import ./scripts/cdg.nix;
  };
}
