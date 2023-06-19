''
export EDITOR=nvim
export DIRENV_LOG_FORMAT=

alias hmup="home-manager switch --flake '$HOME/Documents/projects/nixos#bryan'";
alias nixup="sudo nixos-rebuild switch --flake '$HOME/Documents/projects/nixos#socrates'";

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

source ~/Documents/projects/ldv/ldv.sh

set -o vi
''
