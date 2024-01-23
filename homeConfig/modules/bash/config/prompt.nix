''
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
  local python_icon=""
  local cur_dir=""

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git_branch="$(git symbolic-ref --short HEAD 2>/dev/null)"

    if [ $? -ne 0 ]; then
      git_branch="$(git rev-parse --short HEAD 2>/dev/null)"
    fi

    git_branch="\[\033[01;31m\]$git_branch 󰘬:\[\033[00m\]"

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

  if [[ -n "$VIRTUAL_ENV" ]]; then
    python_icon="\[\033[01;33m\] \[\033[00m\]"
  fi

  if [ -n "''${IN_NIX_SHELL:+x}" ]; then
    PS1="$cur_dir\n$flake_icon$python_icon\[\033[01;32m\]nixShell>$git_branch\[\033[00m\]"
  else
    if ! is_ssh_session; then
      PS1="\n$cur_dir\n$flake_icon$python_icon\[\033[01;32m\]>$git_branch\[\033[00m\]"
    else
      PS1="\n\[\033[01;34m\]\w\[\033[00m\]\n\[\033[01;32m\]\u@\h:\[\033[00m\] "
    fi
  fi
  unset flake_icon
}
PROMPT_COMMAND="set_ps1_prompt; $PROMPT_COMMAND"
''
