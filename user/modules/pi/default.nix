{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.pi;
  npmGlobal = "${config.home.homeDirectory}/.npm-global";
  piVersion = "0.72.0";

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
      piPkgScope="${npmGlobal}/lib/node_modules/@mariozechner"
      piPkgDir="${npmGlobal}/lib/node_modules/@mariozechner/pi-coding-agent"
      piBin="${npmGlobal}/bin/pi"
      run mkdir -p ${npmGlobal}
      run mkdir -p "${npmGlobal}/bin"
      run mkdir -p "$piPkgScope"
      run mkdir -p "${config.home.homeDirectory}/.pi"
      run mkdir -p "$agentDir"
      if [ -e "$agentDir" ]; then
        run chmod -R u+w "$agentDir"
        run find "$agentDir" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
      fi
      run cp -R ${./agent}/. "$agentDir"/
      run chmod -R u+w "$agentDir"
      run rm -f "$piBin"
      run rm -f "${npmGlobal}/bin"/.pi-*
      run rm -rf "$piPkgDir"
      run rm -rf "$piPkgScope"/.pi-coding-agent-*
      if ! run ${pkgs.nodejs_20}/bin/npm install -g --prefix ${npmGlobal} @mariozechner/pi-coding-agent@${piVersion}; then
        warnEcho "pi-coding-agent install failed (offline or registry error)"
      fi

      if [ ! -f "$piPkgDir/package.json" ]; then
        for candidate in "$piPkgScope"/.pi-coding-agent-*; do
          if [ -f "$candidate/package.json" ]; then
            run rm -rf "$piPkgDir"
            run mv "$candidate" "$piPkgDir"
            break
          fi
        done
      fi

      if [ -f "$piPkgDir/dist/cli.js" ]; then
        run ln -sfn ../lib/node_modules/@mariozechner/pi-coding-agent/dist/cli.js "$piBin"
        run chmod +x "$piPkgDir/dist/cli.js"
      else
        warnEcho "pi-coding-agent install did not produce dist/cli.js"
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
