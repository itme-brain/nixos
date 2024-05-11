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

      initExtra = import ./config/prompt.nix { inherit lib config; };
      bashrcExtra = import ./config/bashrc.nix;
      shellAliases = import ./config/alias.nix;

      shellOptions = [
        "set -o vi"
      ];
    };

    programs = {
      ripgrep.enable = true;
      lsd = {
        enable = true;
        enableAliases = true;
      };
    };
  };
}
