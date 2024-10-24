{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.dev;

in
{ options.modules.user.dev = { enable = mkEnableOption "Enable development module"; };
  imports = [ ./modules ];
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nix-init
      nix-prefetch-git
      nurl

      pkg-config
      qrencode

      docker
      virt-manager
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

    home.sessionVariables = {
      DIRENV_LOG_FORMAT = "";
    };
  };
}
