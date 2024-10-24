{ lib, config, ... }:

with lib;
let
  cfg = config.modules.user.bash;

in
{ options.modules.user.bash = { enable = mkEnableOption "Enable BASH shell module"; };
  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;

      initExtra = import ./config/prompt.nix { inherit lib config; };
      bashrcExtra = import ./config/bashrc.nix;
      shellAliases = import ./config/alias.nix { inherit lib config; };
      profileExtra = import ./config/shellHook.nix { inherit lib config; };
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
