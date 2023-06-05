{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.git;

in
{
  options.modules.git = { enable = mkEnableOption "git"; };
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      extraConfig = {
        init = { defaultBranch = "main"; };
      };
    };

    home.file = {
      ".gitconfig".source = ./gitconfig;
    };
  };
}
