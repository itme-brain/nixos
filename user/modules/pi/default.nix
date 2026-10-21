{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.pi;
  npmGlobal = "${config.home.homeDirectory}/.npm-global";
  piPackageScope = "@earendil-works";
  piPackageName = "pi-coding-agent";
  piVersion = "1.3.0";
  installPi = pkgs.writeShellScript "install-pi-coding-agent" ''
    export PATH="${lib.makeBinPath [ pkgs.nodejs pkgs.coreutils ]}:$PATH"
    export NPM_CONFIG_FETCH_RETRIES=0
    export NPM_CONFIG_FETCH_TIMEOUT=15000
    piPkgScope="${npmGlobal}/lib/node_modules/${piPackageScope}"
    piBin="${npmGlobal}/bin/pi"
    agentDir="${config.home.homeDirectory}/.pi/agent"
    rm -f "${npmGlobal}/bin"/.pi-*
    rm -rf "$piPkgScope"/.${piPackageName}-*
    if ! ${pkgs.nodejs}/bin/npm install -g --prefix ${npmGlobal} ${piPackageScope}/${piPackageName}@${piVersion}; then
      echo "pi-coding-agent install failed (offline or registry error)" >&2
      exit 1
    fi
    if [ ! -x "$piBin" ]; then
      echo "npm did not create $piBin" >&2
      exit 1
    fi
    for ext in "$agentDir"/extensions/*; do
      if [ -f "$ext/package.json" ]; then
        if [ -f "$ext/package-lock.json" ]; then
          ${pkgs.nodejs}/bin/npm ci --prefix "$ext" || exit 1
        else
          ${pkgs.nodejs}/bin/npm install --prefix "$ext" || exit 1
        fi
      fi
    done
  '';

in
{ options.modules.user.pi = {
    enable = mkEnableOption "user.pi";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ nodejs ];

    home.sessionVariables = {
      NPM_CONFIG_PREFIX = npmGlobal;
    };

    home.sessionPath = [ "${npmGlobal}/bin" ];

    # NixOS can stop networking while Home Manager activates. A network
    # install must not block the switch before networking is restarted.
    systemd.user.services.pi-install = {
      Unit.Description = "Install Pi coding agent and extension dependencies";
      Service = {
        Type = "exec";
        ExecStart = "${installPi}";
        TimeoutStopSec = 10;
      };
      Install.WantedBy = [ "default.target" ];
    };

    home.activation.installPiCodingAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      PATH="${pkgs.nodejs}/bin:$PATH"
      agentDir="${config.home.homeDirectory}/.pi/agent"
      piPkgScope="${npmGlobal}/lib/node_modules/${piPackageScope}"
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
        --checksum \
        --delete \
        --exclude-from=${./agent}/.gitignore \
        ${./agent}/ "$agentDir"/
      run chmod -R u+w "$agentDir"
      if [ -f "$agentDir/auth.json" ]; then
        run chmod 600 "$agentDir/auth.json"
      fi
    '';
  };
}
