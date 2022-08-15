#!/bin/bash

# ~/.bashrc: executed by bash(1) for non-login shells.
set -uo pipefail

DOTFILES_PATH="$HOME/.homesick/repos/dotfiles/"
export DOTFILES_PATH

BASHRCD=(
  "$DOTFILES_PATH/bashrc.d"
  "$HOME/.bashrc_local"
)

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

set +uo pipefail
