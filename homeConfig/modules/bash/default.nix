{ lib, config, ... }:

with lib;
let
  hostname = config.systemName;
  cfg = config.modules.bash;
  socratesConfigs = {
      initExtra = import ./config/desktop/prompt.nix;
      profileExtra = import ./config/desktop/bashprofile.nix;
      bashrcExtra = import ./config/desktop/bashrc.nix;
      shellAliases = import ./config/desktop/alias.nix;
  };
  archimedesConfigs = {
      initExtra = import ./config/server/prompt.nix;
      profileExtra = import ./config/server/bashprofile.nix;
      bashrcExtra = import ./config/server/bashrc.nix;
      shellAliases = import ./config/server/alias.nix;
  };
  selectedConfig =
    if hostname == "archimedes"
      then archimedesConfigs
    else socratesConfigs;
in
{ options.modules.bash = { enable = mkEnableOption "bash"; };
  config = mkIf cfg.enable {
    programs = {
      bash = {
        enable = true;
        enableCompletion = true;
        initExtra = selectedConfig.initExtra;
        profileExtra = selectedConfig.profileExtra;
        bashrcExtra = selectedConfig.bashrcExtra;
        shellAliases = selectedConfig.shellAliases;
      };
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
