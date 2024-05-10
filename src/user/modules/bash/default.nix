{ lib, config, ... }:

with lib;
let
  cfg = config.modules.user.bash;

in
{ options.modules.user.bash = { enable = mkEnableOption "user.bash"; };
  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;

      initExtra = import ./config/prompt.nix;
      profileExtra = import ./config/bashprofile.nix;
      bashrcExtra = import ./config/bashrc.nix;
      shellAliases = import ./config/alias.nix;
    };

    programs = {
      direnv = {
      	enable = true;
        enableBashIntegration = true;
      	nix-direnv.enable = true;
      };
      ripgrep.enable = true;
      lsd = {
        enable = true;
        enableAliases = true;
      };
    };
  };
}
