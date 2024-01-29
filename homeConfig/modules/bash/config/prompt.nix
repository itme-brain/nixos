''
check_ssh() {
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    ssh_PS1="\n\[\033[01;37m\]\u@\h:\[\033[00m\]"
    return 0
  fi
}

check_venv() {
  if [ -n "$VIRTUAL_ENV" ]; then
    local python_icon="\[\033[01;33m\] \[\033[00m\]"
    venv_icons+="$python_icon"
  elif [ -d  "''${git_root}/node_modules" ]; then
    local node_icon="\[\033[01;93m\]󰌞 \[\033[00m\]"
    venv_icons+="$node_icon"
  fi
    return 0
}

check_nix() {
  if [ -n "$IN_NIX_SHELL" ]; then
    local nix_icon="\[\033[01;34m\] \[\033[00m\]"
    venv_icons+="$nix_icon"
  else
    unset venv_icons
    return 0
  fi
}

set_git_dir() {
  if [ "$git_curr_dir" == "." ]; then
    working_dir="\[\033[01;34m\] $git_root_dir\[\033[00m\]"
    return 0
  else
    working_dir="\[\033[01;34m\] $git_root_dir/$git_curr_dir\[\033[00m\]"
    return 0
  fi
}

check_in_project() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    local git_branch=$(git branch --show-current 2>/dev/null)
    git_branch=''${git_branch:-$(git rev-parse --short HEAD)}

    local git_dir=$(git rev-parse --git-dir)
    local git_root=$(dirname "$(realpath "$git_dir")")

    local git_curr_dir=$(realpath --relative-to="$git_root" .)
    local git_root_dir=$(basename "$git_root")

    git_branch_PS1="\[\033[01;31m\]$git_branch 󰘬:\[\033[00m\]"

    set_git_dir
    check_venv
}

function set_prompt() {
  local green_arrow="\[\033[01;32m\]>> "
  local white_text="\[\033[00m\]"
  local working_dir="\[\033[01;34m\]\w\[\033[00m\]"

  local ssh_PS1
  local venv_icons
  local git_branch_PS1

  check_ssh
  check_nix
  check_in_project

  PS1="$ssh_PS1\n$working_dir\n$venv_icons$green_arrow$git_branch_PS1$white_text"
  return 0
}

PROMPT_COMMAND="set_prompt"
''
