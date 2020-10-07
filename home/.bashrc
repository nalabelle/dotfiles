# ~/.bashrc: executed by bash(1) for non-login shells.

ADDITIONAL_PATHS=(
  "$HOME/.bin"
  "$HOME/.local/bin"
  #osx: homebrew mysql-client
  /usr/local/opt/mysql-client/bin
)

BASH_COMPLETION=(
  /etc/bash_completion
  /usr/share/bash-completion/bash_completion
  /usr/local/etc/profile.d/bash_completion.sh
  /usr/local/etc/bash_completion.d
  "$HOME/.git-completion.bash"
)

ADDITIONAL_SCRIPTS=(
  #osx: homebrew asdf
  # maybe move to something using `brew --prefix`?
  /usr/local/opt/asdf/asdf.sh
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
      _source "$l_path/*"
    elif [ -r "$l_path" ]; then
      # shellcheck disable=SC1090
      . "$l_path"
    fi
  done
  local l_path="$1"
}

_path "${ADDITIONAL_PATHS[@]}"
_source "${BASH_COMPLETION[@]}"
_source "${ADDITIONAL_SCRIPTS[@]}"

if [ -d "$HOME/.homesick" ]; then
  _source "$HOME/.homesick/repos/homeshick/homeshick.sh"
  _source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
  homeshick --quiet refresh
fi

export GOPATH="$HOME/go"
_path "${GOPATH}/bin"

export PERLBREW_ROOT="$HOME/.perlbrew"
_source "$PERLBREW_ROOT/etc/bashrc"

export PYTHONPYCACHEPREFIX="$HOME/.cache/pycache"

# If not running interactively, bail here
if [ -z "$PS1" ]; then
  _source "$HOME/.local/bashrc"
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

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
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

# known-hosts autocomplete
complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | \
    sed -e s/,.*//g | uniq | grep -v "\["`;)" ssh

_source "$HOME/.local/bashrc"

unset ADDITIONAL_PATHS
unset BASH_COMPLETION
