#!/bin/bash -e
# Parts from the homeshick wiki, specifically
# https://gist.github.com/andsens/2913223

# Paste this into ssh
# curl -sL https://gist.github.com/andsens/2913223/raw/bootstrap_homeshick.sh | tar -xzO | /bin/bash -ex
# When forking, you can get the URL from the raw (<>) button.

#./gnome-terminal.xoria256.sh

#$aptget install -y tmux vim git

### Install homeshick ###
if [ ! -d $HOME/.homesick/repos/homeshick ]; then
  git clone git://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
  . $HOME/.homesick/repos/homeshick/homeshick.sh
else
  . $HOME/.homesick/repos/homeshick/homeshick.sh
fi

if [ ! -d $HOME/.homesick/repos/dotfiles ]; then
  homeshick clone git://github.com/nalabelle/dotfiles.git
fi

# Install Vundle
if [ ! -d $HOME/.vim/bundle/Vundle.vim ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

# Install TPM
if [ ! -d $HOME/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "Completed"
