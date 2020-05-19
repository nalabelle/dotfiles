# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.

if [ -d "$HOME/.bin" ]; then
  PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

# Go bin directory support
export GOPATH="$HOME/go"
if [ -d "$GOPATH" ]; then
  if [ -d "${HOME}/go/bin" ]; then
    export PATH=$PATH:${HOME}/go/bin
  fi
fi

export PERLBREW_ROOT="$HOME/.perlbrew"
if [ -s "$PERLBREW_ROOT/etc/bashrc" ]; then
  source "$PERLBREW_ROOT/etc/bashrc"
fi

#Let's use vim
export EDITOR=vim

# set up bashrc
if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

