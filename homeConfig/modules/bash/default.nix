{ lib, config, ... }:

with lib;
let 
  cfg = config.modules.bash;

in 
{ options.modules.bash = { enable = mkEnableOption "bash"; };
  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;

      initExtra = import ./config/prompt.nix;
      profileExtra = import ./config/bashprofile.nix;
      bashrcExtra = import ./config/bashrc.nix;
      shellAliases = import ./config/alias.nix;
    };

    services.gpg-agent.enableBashIntegration = true;
    programs = {
      direnv = {
      	enable = true;
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
