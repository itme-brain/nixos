{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.pi;
  npmGlobal = "${config.home.homeDirectory}/.npm-global";
  piPackageScope = "@earendil-works";
  piPackageName = "pi-coding-agent";
  piVersion = "0.85.1";
  piWebPackage = "@jmfederico/pi-web";
  piWebVersion = "1.202609.0";

in
{ options.modules.user.pi = {
    enable = mkEnableOption "user.pi";

    web = {
      enable = mkEnableOption "PI WEB for persistent browser-controlled Pi sessions";

      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "PI WEB listen address. Keep this on loopback and publish it through the VPN gateway.";
      };

      port = mkOption {
        type = types.port;
        default = 8504;
        description = "PI WEB loopback listen port";
      };
    };
  };
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

      ${optionalString cfg.web.enable ''
        piWebBin="${npmGlobal}/bin/pi-web"
        PATH="${makeBinPath [ pkgs.python3 pkgs.gnumake pkgs.gcc ]}:$PATH"
        export npm_config_python="${pkgs.python3}/bin/python3"
        if ! run ${pkgs.nodejs}/bin/npm install -g \
          --prefix ${npmGlobal} \
          --allow-scripts=node-pty \
          ${piWebPackage}@${piWebVersion}; then
          warnEcho "PI WEB install failed (offline or registry error)"
        else
          # The published package's bin entrypoints are not executable in its
          # tarball. npm normally fixes their mode, but an interrupted native
          # node-pty build can leave repaired installs at 0644.
          run chmod u+x \
            "${npmGlobal}/lib/node_modules/${piWebPackage}/dist/cli.js" \
            "${npmGlobal}/lib/node_modules/${piWebPackage}/dist/server/index.js" \
            "${npmGlobal}/lib/node_modules/${piWebPackage}/dist/server/sessiond.js"
          if [ ! -x "$piWebBin" ]; then
            warnEcho "PI WEB installed but npm did not create an executable $piWebBin"
          fi
        fi
      ''}

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

    systemd.user.services = mkIf cfg.web.enable {
      pi-web-sessiond = {
        Unit = {
          Description = "PI WEB session daemon";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = ''/usr/bin/env /run/current-system/sw/bin/bash -lc "exec pi-web-sessiond"'';
          Restart = "on-failure";
          RestartSec = 2;
          Environment = [
            ''"PI_WEB_HOST=${cfg.web.host}"''
            ''"PI_WEB_PORT=${toString cfg.web.port}"''
          ];
        };
        Install.WantedBy = [ "default.target" ];
      };

      pi-web = {
        Unit = {
          Description = "PI WEB server";
          After = [ "network-online.target" "pi-web-sessiond.service" ];
          Wants = [ "network-online.target" "pi-web-sessiond.service" ];
        };
        Service = {
          Type = "simple";
          ExecStart = ''/usr/bin/env /run/current-system/sw/bin/bash -lc "exec pi-web-server"'';
          Restart = "on-failure";
          RestartSec = 2;
          Environment = [
            ''"PI_WEB_HOST=${cfg.web.host}"''
            ''"PI_WEB_PORT=${toString cfg.web.port}"''
          ];
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
  };
}
