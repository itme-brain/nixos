{ lib, config, ... }:

with lib;
let
  sys = config.systemType;
  cfg = config.modules.bash;
  pcConfigs = {
      initExtra = import ./config/desktop/prompt.nix;
      profileExtra = import ./config/desktop/bashprofile.nix;
      bashrcExtra = import ./config/desktop/bashrc.nix;
      shellAliases = import ./config/desktop/alias.nix;
  };
  serverConfigs = {
      initExtra = import ./config/server/prompt.nix;
      profileExtra = import ./config/server/bashprofile.nix;
      bashrcExtra = import ./config/server/bashrc.nix;
      shellAliases = import ./config/server/alias.nix;
  };
  selectedConfig =
    if sys == "server"
      then serverConfigs
    else pcConfigs;
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
