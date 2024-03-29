{ lib, pkgs, config, ... }:

with lib;
  let cfg = config.modules.user.git;

in
{ options.modules.user.git = { enable = mkEnableOption "user.git"; };
  config = mkIf cfg.enable {
    programs = {
      git = {
        enable = true;
      } // config.user.gitConfig;
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
