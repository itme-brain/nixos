{ lib, pkgs, config, ... }:

with lib;
  let cfg = config.modules.git;

in
{ options.modules.git = { enable = mkEnableOption "git"; };
  config = mkIf cfg.enable {
    programs = {
      git = import ./config/git.nix;
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
