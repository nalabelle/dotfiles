# ~/.bashrc: executed by bash(1) for non-login shells.
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

profile_paths=(
  "$HOME/.bin"
  "$HOME/.local/bin"
  #osx: homebrew mysql-client
  /usr/local/opt/mysql-client/bin
)
trap "unset profile_paths" EXIT

function add_to_path {
  l_path="$1"
  if [ -d "$l_path" ]; then
    PATH="$l_path:$PATH"
  fi
  unset l_path
}

for path in "${profile_paths[@]}"; do
  add_to_path "$path"
done
export PATH=$PATH

export GOPATH="$HOME/go"
add_to_path "${GOPATH}/bin"

export PERLBREW_ROOT="$HOME/.perlbrew"
if [ -d "$PERLBREW_ROOT" ]; then
  if [ -s "$PERLBREW_ROOT/etc/bashrc" ]; then
    source "$PERLBREW_ROOT/etc/bashrc"
  fi
fi

# If not running interactively, bail here
if [ -z "$PS1" ]; then
  if [ -f ~/.local/bashrc ]; then
    . ~/.local/bashrc
  fi
  return
fi


# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

#use vi mode instead of emacs
set -o vi
#remove escape lag
export KEYTIMEOUT=1


# set color
color_prompt=
case "$TERM" in
  xterm-color) color_prompt=yes;;
  xterm-256color) color_prompt=yes;;
esac

if [ -z "$color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
      else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  # enable color support of ls and also add handy aliases
  if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
  fi

  # enable color support of ls for OSX
  if [[ "$OSTYPE" == "darwin"* || "$OSTYPE" == "freebsd"* ]]; then
    alias ls='ls -G'
    alias grep='grep --color=auto'
  fi

  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt

# let's color our man pages
# from archlinux wiki:
man() {
  env LESS_TERMCAP_mb=$(printf "\e[1;31m") \
      LESS_TERMCAP_md=$(printf "\e[1;31m") \
      LESS_TERMCAP_me=$(printf "\e[0m") \
      LESS_TERMCAP_se=$(printf "\e[0m") \
      LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
      LESS_TERMCAP_ue=$(printf "\e[0m") \
      LESS_TERMCAP_us=$(printf "\e[1;32m") \
      man "$@"
}

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  elif [ -r "/usr/local/etc/profile.d/bash_completion.sh" ]; then
    . "/usr/local/etc/profile.d/bash_completion.sh"
  fi
fi

# git autocomplete
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi


if [ -d "$HOME/.homesick" ]; then
  source "$HOME/.homesick/repos/homeshick/homeshick.sh"
  source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
  homeshick --quiet refresh
fi

# known-hosts autocomplete
complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | \
    sed -e s/,.*//g | uniq | grep -v "\["`;)" ssh


if [ -f ~/.local/bashrc ]; then
  . ~/.local/bashrc
fi
