{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.pi;
  npmGlobal = "${config.home.homeDirectory}/.npm-global";
in
{ options.modules.user.pi = { enable = mkEnableOption "user.pi"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ nodejs_20 ];

    home.sessionVariables = {
      LLAMACPP_BASE_URL = "https://ai.ramos.codes/v1";
      NPM_CONFIG_PREFIX = npmGlobal;
    };

    home.sessionPath = [ "${npmGlobal}/bin" ];

    home.file.".pi/agent" = {
      source = ./agent;
      recursive = true;
    };

    programs.bash.initExtra = ''
      export LLAMACPP_API_KEY=$(cat /run/secrets/LLAMA_API_KEY)
    '';
  };
}
