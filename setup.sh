#!/bin/sh
set -e

VIM=$(which vim)
TMUX=$(which tmux)
GIT=$(which git)

if [ ! -f $VIM ] || [ ! -f $TMUX ] || [ ! -f $GIT ]; then
  printf "You should install git, tmux, and vim."
  exit 1
fi

### Install homeshick ###
if [ ! -d $HOME/.homesick/repos/homeshick ]; then
  git clone git://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
  . $HOME/.homesick/repos/homeshick/homeshick.sh
else
  . $HOME/.homesick/repos/homeshick/homeshick.sh
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

