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

    programs.bash.initExtra = ''
      export LLAMACPP_API_KEY=$(cat /run/secrets/LLAMA_API_KEY)
    '';

    home.activation.installPiCodingAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      PATH="${pkgs.nodejs_20}/bin:$PATH"
      agentDir="${config.home.homeDirectory}/.pi/agent"
      run mkdir -p ${npmGlobal}
      run mkdir -p "${config.home.homeDirectory}/.pi"
      run mkdir -p "$agentDir"
      if [ -e "$agentDir" ]; then
        run chmod -R u+w "$agentDir"
        run find "$agentDir" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
      fi
      run cp -R ${./agent}/. "$agentDir"/
      run chmod -R u+w "$agentDir"
      if ! run ${pkgs.nodejs_20}/bin/npm install -g --prefix ${npmGlobal} @mariozechner/pi-coding-agent@${piVersion}; then
        warnEcho "pi-coding-agent install failed (offline or registry error)"
      fi

      for ext in "$agentDir"/extensions/*; do
        if [ -f "$ext/package.json" ]; then
          if [ -f "$ext/package-lock.json" ]; then
            if ! run ${pkgs.nodejs_20}/bin/npm ci --prefix "$ext"; then
              warnEcho "pi extension dependency install failed for $ext"
            fi
          else
            if ! run ${pkgs.nodejs_20}/bin/npm install --prefix "$ext"; then
              warnEcho "pi extension dependency install failed for $ext"
            fi
          fi
        fi
      done
    '';
  };
}
