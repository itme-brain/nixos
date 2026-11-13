{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.pi;
  nodeRuntime = pkgs.unstable.nodejs;
  # Pi's package manager needs npm, but Node need not be in the user profile.
  piSettings = pkgs.writeText "pi-settings.json" (builtins.toJSON (
    builtins.fromJSON (builtins.readFile ./agent/settings.json) // {
      npmCommand = [ "${nodeRuntime}/bin/npm" ];
    }
  ));
  installExtensionDependencies = pkgs.writeShellScript "install-pi-extension-dependencies" ''
    set -eu
    export PATH="${lib.makeBinPath [ nodeRuntime pkgs.coreutils ]}:$PATH"
    export NPM_CONFIG_FETCH_RETRIES=0
    export NPM_CONFIG_FETCH_TIMEOUT=15000
    agentDir="${config.home.homeDirectory}/.pi/agent"
    for ext in "$agentDir"/extensions/*; do
      if [ -f "$ext/package.json" ]; then
        if [ -f "$ext/package-lock.json" ]; then
          npm ci --prefix "$ext"
        else
          npm install --prefix "$ext"
        fi
      fi
    done
  '';

in
{ options.modules.user.pi = {
    enable = mkEnableOption "user.pi";
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.unstable.pi-coding-agent ];

    # Only local extension dependencies need a network install. Keep this out
    # of activation, where NixOS may temporarily stop networking.
    systemd.user.services.pi-extension-dependencies = {
      Unit.Description = "Install Pi extension dependencies";
      Service = {
        Type = "exec";
        ExecStart = "${installExtensionDependencies}";
        TimeoutStopSec = 10;
      };
      Install.WantedBy = [ "default.target" ];
    };

    home.activation.installPiCodingAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      agentDir="${config.home.homeDirectory}/.pi/agent"
      # Retire only the legacy launcher owned by this module. Otherwise an
      # existing shell's npm PATH can shadow the nixpkgs package after switching.
      piBin="${config.home.homeDirectory}/.npm-global/bin/pi"
      if [ -L "$piBin" ]; then
        case "$(readlink "$piBin")" in
          /nix/store/*-pi/bin/pi) run unlink "$piBin" ;;
        esac
      fi
      run mkdir -p "$agentDir"
      if [ -e "$agentDir" ]; then
        run chmod -R u+w "$agentDir"
      fi
      run ${pkgs.rsync}/bin/rsync \
        --archive \
        --checksum \
        --delete \
        --chmod=u+w \
        --exclude-from=${./agent}/.gitignore \
        ${./agent}/ "$agentDir"/
      run ${pkgs.coreutils}/bin/install -m 644 ${piSettings} "$agentDir/settings.json"
      run chmod -R u+w "$agentDir"
      if [ -f "$agentDir/auth.json" ]; then
        run chmod 600 "$agentDir/auth.json"
      fi
    '';
  };
}
