{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.pi;
  npmGlobal = "${config.home.homeDirectory}/.npm-global";
  piVersion = "0.70.5";

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

    home.activation.installPiCodingAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      PATH="${pkgs.nodejs_20}/bin:$PATH"
      run mkdir -p ${npmGlobal}
      if ! run ${pkgs.nodejs_20}/bin/npm install -g --prefix ${npmGlobal} @mariozechner/pi-coding-agent@${piVersion}; then
        warnEcho "pi-coding-agent install failed (offline or registry error)"
      fi
    '';
  };
}
