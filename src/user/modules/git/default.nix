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
        package = pkgs.gitSVN;
        extraConfig = {
          init = { defaultBranch = "master"; };
          #format = { pretty = "oneline"; };
          #log = { abbrevCommit = true; };
          mergetool = {
            vimdiff = {
              trustExitCode = true;
            };
            keepBackup = false;
          };
          merge = { 
            tool = "vimdiff"; 

          };
          safe = { 
            directory = [
              "/etc/nixos"
              "/boot"
            ];
          };
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
