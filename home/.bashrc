# ~/.bashrc: executed by bash(1) for non-login shells.

BASHRCD=(
  "$HOME/.bashrc.d"
  "$HOME/.bashrc_local"
)

function get_dotfiles_path() {
  MY_PATH=$(dirname "${BASH_SOURCE[0]}")
  DOTFILES_PATH=$(realpath "$MY_PATH")
  echo "$DOTFILES_PATH"
}

function _path {
  local paths=("$@")
  for l_path in "${paths[@]}"; do
    if [ -d "$l_path" ]; then
      if [[ ! $PATH == *"$l_path"* ]]; then
        PATH="$l_path:$PATH"
      fi
    fi
  done

  export PATH=$PATH
}

function _source {
  local paths=("$@")
  for l_path in "${paths[@]}"; do
    if [ -d "$l_path" ]; then
      _source "$l_path"/*
    elif [ -r "$l_path" ]; then
      # shellcheck disable=SC1090
      . "$l_path"
    fi
  done
  local l_path="$1"
}

_source "${BASHRCD[@]}"
unset BASHRCD
