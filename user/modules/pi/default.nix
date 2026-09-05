{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.pi;
  npmGlobal = "${config.home.homeDirectory}/.npm-global";
  piPackageScope = "@earendil-works";
  piPackageName = "pi-coding-agent";
  piVersion = "0.85.0";

in
{ options.modules.user.pi = { enable = mkEnableOption "user.pi"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ nodejs ];

    home.sessionVariables = {
      NPM_CONFIG_PREFIX = npmGlobal;
    };

    home.sessionPath = [ "${npmGlobal}/bin" ];

    home.activation.installPiCodingAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      PATH="${pkgs.nodejs}/bin:$PATH"
      agentDir="${config.home.homeDirectory}/.pi/agent"
      piPkgScope="${npmGlobal}/lib/node_modules/${piPackageScope}"
      piBin="${npmGlobal}/bin/pi"
      run mkdir -p ${npmGlobal}
      run mkdir -p "${npmGlobal}/bin"
      run mkdir -p "$piPkgScope"
      run mkdir -p "${config.home.homeDirectory}/.pi"
      run mkdir -p "$agentDir"
      if [ -e "$agentDir" ]; then
        run chmod -R u+w "$agentDir"
      fi
      run ${pkgs.rsync}/bin/rsync \
        --archive \
        --delete \
        --exclude-from=${./agent}/.gitignore \
        ${./agent}/ "$agentDir"/
      run chmod -R u+w "$agentDir"
      if [ -f "$agentDir/auth.json" ]; then
        run chmod 600 "$agentDir/auth.json"
      fi
      run rm -f "${npmGlobal}/bin"/.pi-*
      run rm -rf "$piPkgScope"/.${piPackageName}-*
      if ! run ${pkgs.nodejs}/bin/npm install -g --prefix ${npmGlobal} ${piPackageScope}/${piPackageName}@${piVersion}; then
        warnEcho "pi-coding-agent install failed (offline or registry error)"
      elif [ ! -x "$piBin" ]; then
        warnEcho "pi-coding-agent installed but npm did not create $piBin"
      fi

      for ext in "$agentDir"/extensions/*; do
        if [ -f "$ext/package.json" ]; then
          if [ -f "$ext/package-lock.json" ]; then
            if ! run ${pkgs.nodejs}/bin/npm ci --prefix "$ext"; then
              warnEcho "pi extension dependency install failed for $ext"
            fi
          else
            if ! run ${pkgs.nodejs}/bin/npm install --prefix "$ext"; then
              warnEcho "pi extension dependency install failed for $ext"
            fi
          fi
        fi
      done
    '';
  };
}
