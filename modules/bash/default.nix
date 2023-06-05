{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.bash;

in {
  options.modules.bash = { enable = mkEnableOption "bash"; };
  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;

      initExtra = ''
        eval "$(direnv hook bash)"

        is_ssh_session() {
          if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
            return 0
          else
            return 1
          fi
        }

        function set_ps1_prompt() {
          local git_branch=""
          local flake_icon=""
          local cur_dir=""

          if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            git_branch="$(git symbolic-ref --short HEAD 2>/dev/null)"

            if [ $? -ne 0 ]; then
              git_branch="$(git rev-parse --short HEAD 2>/dev/null)"
            fi

            git_branch=" \[\033[01;31m\]$git_branch󰘬:\[\033[00m\]"

            if [ -f "$(git rev-parse --show-toplevel)/flake.nix" ]; then
                # If it exists, set the flake icon and color it blue
                flake_icon="\[\033[01;34m\] \[\033[00m\]"
            fi

            git_root="$(basename "$(git rev-parse --show-toplevel)")"

            cur_dir=$(realpath --relative-to=$(git rev-parse --show-toplevel) .)
            if [ "$cur_dir" == "." ]; then
              cur_dir="\[\033[01;34m\] $git_root\[\033[00m\]"
            else
              cur_dir="\[\033[01;34m\] $git_root/$cur_dir\[\033[00m\]"
            fi
          else
            cur_dir="\[\033[01;34m\]\w\[\033[00m\]"
          fi

          if [ -n "${IN_NIX_SHELL:+x}" ]; then
            PS1="$cur_dir\n$flake_icon\[\033[01;32m\]nixShell>$git_branch\[\033[00m\]"
          else
            if ! is_ssh_session; then
              PS1="\n$cur_dir\n$flake_icon\[\033[01;32m\]>$git_branch\[\033[00m\]"
            else
              PS1="\n\[\033[01;34m\]\w\[\033[00m\]\n\[\033[01;32m\]\u@\h:\[\033[00m\] "
            fi
          fi
          unset flake_icon
        }
        PROMPT_COMMAND="set_ps1_prompt; $PROMPT_COMMAND"

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

        if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
          ldv "$@"
        fi
      '';

      shellAliases = {
        ls = "lsd";
        hmup = "home-manager switch --flake '$HOME/Documents/projects/nixos#bryan'";
        nixup = "sudo nixos-rebuild switch --flake '$HOME/Documents/projects/nixos#socrates'";
      };
    };
  };
}
