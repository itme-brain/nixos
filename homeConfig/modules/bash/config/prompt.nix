''
check_ssh() {
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    ssh_PS1="\n\[\033[01;37m\]\u@\h:\[\033[00m\]"
  fi
}

function check_venv() {
  if [ -n "''${IN_NIX_SHELL}" ]; then
    if [ -n "$VIRTUAL_ENV" ]; then
      python_icon="\[\033[01;33m\] \[\033[00m\]"
    fi
    nix_icon="\[\033[01;34m\] \[\033[00m\]"
  else
    unset nix_icon python_icon
  fi
}

function set_git_dir() {
  local git_curr_dir=$(realpath --relative-to="$git_root" .)
  if [ "$git_curr_dir" == "." ]; then
    working_dir="\[\033[01;34m\] $git_root_dir\[\033[00m\]"
  else
    working_dir="\[\033[01;34m\] $git_root_dir/$git_curr_dir\[\033[00m\]"
  fi
}

function check_git() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local git_branch=$(git branch --show-current)
    if [ -z "$git_branch" ]; then
      git_branch=$(git rev-parse --short HEAD)
    fi

    local git_root=$(git rev-parse --show-toplevel)
    local git_root_dir=$(basename "$git_root")
    git_branch_PS1="\[\033[01;31m\]$git_branch 󰘬:\[\033[00m\]"

    set_git_dir
  fi
}

function set_prompt() {
  local working_dir="\[\033[01;34m\]\w\[\033[00m\]"
  local green_arrow="\[\033[01;32m\]>> "
  local white_text="\[\033[00m\]"

  check_ssh
  check_venv
  check_git

  PS1="$ssh_PS1\n$working_dir\n$nix_icon$python_icon$green_arrow$git_branch_PS1$white_text"
  unset git_branch_PS1
}

PROMPT_COMMAND="set_prompt"
''
