''
function cdg() {
  if [[ $1 == "--help" ]]; then
    echo "A simple utility for navigating to the root of a git repo"
    return 0
  fi

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
''
