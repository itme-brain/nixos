{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.utils.dev;

in
{ options.modules.user.utils.dev = { enable = mkEnableOption "user.utils.dev"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nix-init
      nix-prefetch-git
      nurl

      docker

      pkg-config
      qrencode

      docker
    ];

    programs = {
      bash = {
        initExtra = mkAfter ''
          ${import ./config/penpot.nix}
        '';
      };
      direnv = {
        enable = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };
    };

    home.sessionVariables = {
      DIRENV_LOG_FORMAT = " ";
    };
  };

  programs.bash.bashrcExtra = ''
    function penpot() {
      case "$1" in
        run)
          sudo docker compose -p penpot -f ~/Documents/tools/penpot/docker-compose.yaml up -d >/dev/null 2>&1
          nohup bash -c '(sleep 10 && if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                            xdg-open "http://localhost:9001"
                          elif [[ "$OSTYPE" == "darwin"* ]]; then
                            open "http://localhost:9001"
                          fi)' >/dev/null 2>&1 &
          echo "Started penpot on http://localhost:9001"
          ;;
        stop)
          echo "Stopping penpot"
          sudo docker compose -p penpot -f ~/Documents/tools/penpot/docker-compose.yaml down >/dev/null 2>&1
          ;;
        update)
          sudo docker compose -f ~/Documents/tools/penpot/docker-compose.yaml pull
          echo "Updated penpot!"
          ;;
        help)
          xdg-open "https://help.penpot.app/"
          echo "Opened penpot help page in your browser."
          ;;
        *)
          echo "Usage: penpot {run|stop|update|help}"
          ;;
      esac
    }
  '';
}
