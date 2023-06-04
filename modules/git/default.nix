{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.git;

in
{
  options.modules.git = { enable = mkEnableOption "git"; };
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "Bryan Ramos";
      userEmail = "bryan@ramos.codes";
      extraConfig = {
        init = { defaultBranch = "main"; };
      };
    };
  };
}
