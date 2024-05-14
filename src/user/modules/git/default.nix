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
        extraConfig = {
          init = { defaultBranch = "master"; };
          format = { pretty = "oneline"; };
          log = { abbrevCommit = true; };
          mergetool = {
            vimdiff = {
              trustExitCode = true;
            };
          };
          merge = { tool = "vimdiff"; };
          safe = { directory = "/etc/nixos"; };
        };
        ignores = [
          "node_modules"
          ".direnv"
          "dist-newstyle"
          ".nuxt/"
          ".output/"
          "dist"
          "result"
        ];
      } // config.user.gitConfig;
      gh = {
        enable = true;
        settings.git_protocol = "ssh";
      };
    };

    home.packages = with pkgs; [
      git-crypt
    ];

    programs.bash.initExtra = import ./config/bashScripts/cdg.nix;
  };
}
