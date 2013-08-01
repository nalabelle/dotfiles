# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

# Sometimes I like to hide it.
if [ -d "$HOME/.bin" ]; then
  PATH="$HOME/.bin:$PATH"
fi


# MacPorts Installer addition on 2012-09-09_at_16:31:27: adding an appropriate PATH variable for use with MacPorts.
# export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.

if [ -d "/opt/local/bin" ] && [ -d "/opt/local/sbin" ]; then
    PATH=/opt/local/bin:/opt/local/sbin:$PATH
fi

# Environment Variables!

# I hate Ruby

# Ruby: Local gem installations
#if [ -d $HOME/.gem/bin ]; then
#  PATH=$PATH:$HOME/.gem/bin
#fi

# Don't install gems into root, unless necessary
#export GEM_HOME=$HOME/.gem
#export GEM_PATH=$HOME/.gem

# select default interpreter
#eval "$(rbenv init -)"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
