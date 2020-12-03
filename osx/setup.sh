#!/bin/sh
set -euox pipefail

VIM="$(which vim || true)"
TMUX="$(which tmux || true)"
GIT=$(which git || true)
_homeshick="$(which homeshick || true)"

if [ ! -f $VIM ] || [ ! -f $TMUX ] || [ ! -f $GIT ]; then
  printf "You should install git, tmux, and vim."
  exit 1
fi

if [ -z "$_homeshick" ]; then
  echo "brew install homeshick"
  exit 1
fi

if [ ! -d $HOME/.homesick/repos/dotfiles ]; then
  homeshick clone git@github.com:nalabelle/dotfiles.git
fi

# Install Vundle
if [ ! -d $HOME/.vim/bundle/Vundle.vim ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

# Install TPM
if [ ! -d $HOME/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

printf "Completed - Remember to install plugins:\n"
printf "\tvim\tPluginInstall\n"
printf "\ttmux\tprefix-I\n"

