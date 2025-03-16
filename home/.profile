# shellcheck shell=sh external-sources=false disable=SC1091
# vim:filetype=sh

DOTFILES="$HOME/.homesick/repos/dotfiles"

# Support Utilities
. "$DOTFILES/shell/util/path"
. "$DOTFILES/shell/util/shell"

# https://wiki.archlinux.org/title/XDG_Base_Directory
# Use XDG dirs for completion and history files
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Path Configs
+path.prepend "PATH" \
  "$DOTFILES/bin" \
  "$HOME/.local/bin" \
  "$HOME/.nix-profile/bin" \
  "$CARGO_HOME/bin"

+path.source \
  "$HOME/.homesick/repos/homeshick/homesick.sh"
#  "$DOTFILES/shell/generic/fzf" \
#  "$HOME/.config/broot/launcher/bash/br"

# If not running interactively, bail here
+shell.non-interactive return

# Environment
export LANG="en_US.UTF-8"
export EDITOR=vim
export PAGER=less

# Don't store less history
export LESSHISTSIZE=0

#remove escape lag in vi mode
export KEYTIMEOUT=1

# set color
case $TERM in
  *'color'*)
    +path.source "$DOTFILES/shell/color/init"
    ;;
esac
