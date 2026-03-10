{ lib, config, ... }:

with lib;
let
  cfg = config.modules.user.bash;

in
{ options.modules.user.bash = { enable = mkEnableOption "user.bash"; };
  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      initExtra = "source ~/.config/bash/bashrc";
      profileExtra = import ./config/shellHook.nix { inherit lib config; };
    };
    
    # .bashrc
    home.file.".config/bash" = {
      source = ./config/bash;
      recursive = true;
    };

    programs = {
      ripgrep.enable = true;
      eza = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = false;
        enableZshIntegration = false;
        enableNushellIntegration = false;
        enableIonIntegration = false;
      };
    };
  };
}
