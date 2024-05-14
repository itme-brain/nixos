{ config, lib, ... }:

with lib;
let
  git = config.modules.user.git;
  gui = config.modules.user.gui.alacritty;

in
''
check_ssh() {
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    ssh_PS1="\n\[\033[01;37m\]\u@\h:\[\033[00m\]"
    return 0
  fi
}

${optionalString git.enable ''
add_icon() {
  local icon=$1
  if [[ ! $venv_icons =~ $icon ]]; then
    venv_icons+="$icon "
  fi
}

remove_icon() {
  local icon=$1
  venv_icons=''${venv_icons//$icon/}
}

${if gui.enable then ''
if [ -n "$DISPLAY" ]; then
  python_icon="\[\033[01;33m\]\[\033[00m\]"
  node_icon="\[\033[01;93m\]󰌞\[\033[00m\]"
  nix_icon="\[\033[01;34m\]\[\033[00m\]"
else
  python_icon="\[\033[01;33m\]py\[\033[00m\]"
  node_icon="\[\033[01;93m\]js\[\033[00m\]"
  nix_icon="\[\033[01;34m\]nix[\033[00m\]"
fi
'' else ''
python_icon="\[\033[01;33m\]venv\[\033[00m\]"
node_icon="\[\033[01;93m\]js\[\033[00m\]"
nix_icon="\[\033[01;34m\]nix[\033[00m\]"
''}

check_venv() {
  if [ -n "$IN_NIX_SHELL" ]; then
    add_icon "$nix_icon"
  else
    remove_icon "$nix_icon"
  fi

  if [ -n "$VIRTUAL_ENV" ]; then
    add_icon "$python_icon"
  else
    remove_icon "$python_icon"
  fi

  if [ -d "''${git_root}/node_modules" ]; then
    add_icon "$node_icon"
  else
    remove_icon "$node_icon"
  fi
}

set_git_dir() {
  ${if gui.enable then ''
  if [ -n "$DISPLAY" ]; then
    project_icon=""
  else
    project_icon="../"
  fi
  '' else ''
  project_icon="../"
  ''}
  local superproject_root=$(git rev-parse --show-superproject-working-tree 2>/dev/null)
  if [[ -n "$superproject_root" ]]; then
    local submodule_name=$(basename "$git_root")

    working_dir="\[\033[01;34m\]$project_icon ''${superproject_root##*/}/$submodule_name$git_curr_dir\[\033[00m\]"
  elif [ "$git_curr_dir" == "." ]; then
    working_dir="\[\033[01;34m\]$project_icon $git_root_dir\[\033[00m\]"
    return 0
  else
    working_dir="\[\033[01;34m\]$project_icon $git_root_dir$git_curr_dir\[\033[00m\]"
    return 0
  fi
}

relative_path() {
  local absolute_target=$(readlink -f "$1")
  local absolute_base=$(readlink -f "$2")
  echo "''${absolute_target#$absolute_base}"
}

check_project() {
  local git_root=$(git rev-parse --show-toplevel 2>/dev/null)

  if [ -n "$git_root" ]; then
    local git_branch=$(git branch --show-current 2>/dev/null)
    git_branch=''${git_branch:-$(git rev-parse --short HEAD 2>/dev/null)}

    local git_curr_dir=$(relative_path "." "$git_root")
    local git_root_dir=$(basename "$git_root")

    ${if gui.enable then ''
    if [ -n "$DISPLAY" ]; then
      git_branch_PS1="\[\033[01;31m\]$git_branch 󰘬:\[\033[00m\]"
    else
      git_branch_PS1="\[\033[01;31m\]$git_branch ~:\[\033[00m\]"
    fi
    '' else ''
    git_branch_PS1="\[\033[01;31m\]$git_branch ~:\[\033[00m\]"
    ''}

    set_git_dir
    check_venv

    return 0
  fi
}
''}
function set_prompt() {
  local green_arrow="\[\033[01;32m\]>> "
  local white_text="\[\033[00m\]"
  local working_dir="\[\033[01;34m\]\w\[\033[00m\]"

  local ssh_PS1

  check_ssh

  ${optionalString git.enable ''
  local venv_icons
  local git_branch_PS1

  check_project
  ''}

  ${if git.enable
    then ''PS1="$ssh_PS1\n$working_dir\n$venv_icons$green_arrow$git_branch_PS1$white_text"''
    else ''PS1="$ssh_PS1\n$working_dir\n$green_arrow$white_text"''
  }
  return 0
}

PROMPT_COMMAND="set_prompt"
''
