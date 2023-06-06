''
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

function ldv() {
if [[ $1 == "help" ]] || [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
  cat << EOF
ldv
A simple utility for setting up development environments effortlessly.
Commands:
  ldv               Start a preconfigured nix shell.
  init              Create a new dev template in the current working directory.
  help              Show available commands and options.

Contributions welcome: https://github.com/itme-brain/ldv
EOF

elif [[ $1 == "init" ]] || [[ $1 == "-i" ]] || [[ $1 == "--init" ]]; then
  if [[ -e ./shell.nix ]] || [[ -e ./.envrc ]]; then
    cat << EOF
Existing environment found.
Initialization cancelled.
EOF
    return
  fi
  
  cat << EOF
Initializing a new environment...
Select an environment:
1. Web
2. Elixir
3. Haskell
EOF

  read -p "Enter the number of your choice: " choice

  case $choice in
    1)
      wget -q https://raw.githubusercontent.com/itme-brain/ldv/main/shells/web.nix -O shell.nix
      wget -q https://raw.githubusercontent.com/itme-brain/ldv/main/utils/flake -O flake.nix
      wget -q https://raw.githubusercontent.com/itme-brain/ldv/main/utils/envrc -O .envrc
      direnv allow
      ;;
    2)
      wget -q https://raw.githubusercontent.com/itme-brain/ldv/main/shells/elixir.nix -O shell.nix
      wget -q https://raw.githubusercontent.com/itme-brain/ldv/main/utils/flake -O flake.nix
      wget -q https://raw.githubusercontent.com/itme-brain/ldv/main/utils/envrc -O .envrc
      direnv allow
      ;;
    3)
      wget -q https://raw.githubusercontent.com/itme-brain/ldv/main/shells/haskell.nix -O shell.nix
      wget -q https://raw.githubusercontent.com/itme-brain/ldv/main/utils/flake -O flake.nix
      wget -q https://raw.githubusercontent.com/itme-brain/ldv/main/utils/envrc -O .envrc
      direnv allow
      ;;
    *)
      echo "Invalid choice."
      ;;
  esac
elif [[ -z $1 ]]; then
  cat << EOF
Select an environment:
1. Web
2. Elixir
3. Haskell
EOF

  read -p "Enter the number of your choice: " choice

  case $choice in
    1)
      (nix develop github:itme-brain/ldv#web)
      ;;
    2)
      (nix develop github:itme-brain/ldv#elixir)
      ;;
    3)
      (nix develop github:itme-brain/ldv#haskell)
      ;;
    # Add more cases here...
    *)
      echo "Invalid choice."
      ;;
  esac
else
  echo "Error: Invalid command. Try 'ldv --help'"
fi
}
''
