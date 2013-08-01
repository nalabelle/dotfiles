# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# Gnome terminal doesn't seem to allow for a way to set the
# xterm*termname customization for 256color so here's a hacky way
# hopefully no other terminals identify themselves as gnome-terminal.
if [ "$COLORTERM" == "gnome-terminal" ] && [ "$TERM" == "xterm" ]; then
  export TERM="$TERM-256color"
  #export TERM="xterm-256color"
fi

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

# Node

# Note, I have a local install in /usr/local or whatever. I don't install things globally (-g).
# I do like to use apps now and then though, and that's where it's handy to have this:
PATH=$PATH:./node_modules/.bin
# No idea if this will break things.

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
