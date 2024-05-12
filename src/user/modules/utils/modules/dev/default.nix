{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.utils.dev;

in
{ options.modules.user.utils.dev = { enable = mkEnableOption "user.utils.dev"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nix-init
      nix-prefetch-git
      nurl

      pkg-config
      qrencode

      docker
    ];

    programs = {
      bash = {
        initExtra = import ./config/penpot.nix;
      };
      direnv = {
        enable = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };
    };

    programs.git.ignores = [
      ".direnv"
    ];

    home.sessionVariables = {
      DIRENV_LOG_FORMAT = " ";
    };
  };
}
