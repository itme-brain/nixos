{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.git;

in
{
  options.modules.git = { enable = mkEnableOption "git"; };
  config = mkIf cfg.enable {
    programs = {
      git = {
        enable = true;
        userName = "Bryan Ramos";
        userEmail = "bryan@ramos.codes";
        signingKey = "F1F3466458452B2DF351F1E864D12BA95ACE1F2D";

        extraConfig = {
          init = { defaultBranch = "main"; };
        };

        ignores = [
          "node_modules"
        ];
      };

      gh = {
        enable = true;
        settings.git_protocol = "ssh";
      };

    };
  };
}
