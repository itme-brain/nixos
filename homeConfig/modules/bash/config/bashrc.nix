''
export EDITOR=nvim
export DIRENV_LOG_FORMAT=

alias hmup="home-manager switch --flake '$HOME/Documents/projects/nixos#bryan'";
alias nixup="sudo nixos-rebuild switch --flake '$HOME/Documents/projects/nixos#socrates'";
alias chat="weechat";

function cdg() {
  if [[ $1 == "--help" ]]; then
    echo "A simple utility for navigating to the root of a git repo"
    return 0
  fi

  # Check for invalid command
  if [[ -n "$1" ]]; then
    echo "Invalid command: $1. Try 'cdg --help'."
    return 1
  fi

  local root_dir
  root_dir=$(git rev-parse --show-toplevel 2>/dev/null)
  local git_status=$?

  if [ $git_status -ne 0 ]; then
    echo "Error: Not a git repo."
    return 1
  fi

  cd "$root_dir"
}

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

source ~/Documents/projects/ldv/ldv.sh

set -o vi

bind 'set completion-ignore-case on'
bind 'set completion-map-case on'
''
