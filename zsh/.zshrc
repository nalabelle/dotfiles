# shellcheck shell=sh external-sources=false disable=SC1091
# vim:filetype=zsh

source $HOME/.profile
[ -d "$XDG_STATE_HOME"/zsh ] || mkdir -p "$XDG_STATE_HOME"/zsh
[ -d "$XDG_CACHE_HOME"/zsh ] || mkdir -p "$XDG_CACHE_HOME"/zsh

HISTFILE="$XDG_STATE_HOME"/zsh/history

bindkey -v
# allow backspacing over characters to left
bindkey -v '^?' backward-delete-char

# https://github.com/zsh-users/zsh-autosuggestions
source $HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# https://github.com/zsh-users/zsh-syntax-highlighting
source $HOME/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# https://github.com/zsh-users/zsh-history-substring-search
source $HOME/.config/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh


# https://linux.die.net/man/1/zshoptions

# Convenience
setopt autocd

# Globbing
setopt nocaseglob
setopt extendedglob
setopt globdots
# Sends unmatched globs to the command
setopt no_nomatch

# How many commands in the history file
SAVEHIST=5000
# How many commands in session history
HISTSIZE=2000
setopt appendhistory
setopt histexpiredupsfirst
setopt histfindnodups
setopt histignorealldups
setopt histignoredups
setopt histnostore
setopt histreduceblanks
setopt incappendhistory
#setopt sharehistory

# Put the !! command in the prompt for changing
setopt histverify

# Corrections
setopt correct

key=(
  BackSpace  "${terminfo[kbs]}"
  Home       "${terminfo[khome]}"
  End        "${terminfo[kend]}"
  Insert     "${terminfo[kich1]}"
  Delete     "${terminfo[kdch1]}"
  Up         "${terminfo[kcuu1]}"
  Down       "${terminfo[kcud1]}"
  Left       "${terminfo[kcub1]}"
  Right      "${terminfo[kcuf1]}"
  PageUp     "${terminfo[kpp]}"
  PageDown   "${terminfo[knp]}"
)






zstyle ':vcs_info:*' check-for-changes
zstyle ':vcs_info:*' unstagedstr ' %F{green}U%f'
zstyle ':vcs_info:*' check-for-staged-changes
zstyle ':vcs_info:*' stagedstr ' %F{blue}S%f'
zstyle ':vcs_info:*' actionformats '%F{008}[%F{yellow}%b%F{008}|%F{red}%a%F{008}]%f%c%u%f'
zstyle ':vcs_info:*' formats  '%F{008}[%F{yellow}%b%c%u%F{008}]%f'
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

+vi-git-untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
     git status --porcelain | grep -m 1 '^??' &>/dev/null
  then
    hook_com[staged]+=' %F{red}T%f'
  fi
}

# Prompt
# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
# %F/%f start stop foreground color
# %K/%k start stop background color
prompt_custom_header_env() {
  if [ -n "$PROMPT_ENV" ]; then
    print - " %F{94}$PROMPT_ENV%f"
  fi
}

X_ZERO='%([BSUbfksu]|([FK]|){*})'
prompt_custom_string_date() {
  # via zsh/datetime
  TZ=UTC strftime "%Y-%m-%d %H:%M:%S.%."
}

prompt_custom_header_date() {
  print -Pn '\n%(?.%F{156}.%F{203})'
  print -P "$(prompt_custom_string_date)%f"
}

prompt_custom_header_rewrite_date() {
  local date_string="$(prompt_custom_string_date) ->"
  local date_string_length=${#${(S%%)date_string//$~X_ZERO/}}
  local C=$(( $COLUMNS - ($date_string_length + 1) ))
  print -P "\033[2F\033[${C}C%F{032}${date_string}%f\033[1E"
  zle reset-prompt
}

prompt_custom_header() {
  local X_ENV="$(prompt_custom_header_env) "
  # path env vcs_info
  local X_HEADER_LEFT="%F{248}%0~%f${X_ENV}${vcs_info_msg_0_}"
  # user@machine
  local X_HEADER_RIGHT="%F{248}%n@%m%f"
  local X_HEADER_LEFT_LENGTH=${#${(S%%)X_HEADER_LEFT//$~X_ZERO/}}
  local X_HEADER_RIGHT_LENGTH=${#${(S%%)X_HEADER_RIGHT//$~X_ZERO/}}
  local X_PRINT_RIGHT
  local X_PROMPTS_WIDTH
  local X_PROMPT_SPACER
  (( X_PROMPTS_WIDTH = (1 + $X_HEADER_LEFT_LENGTH + $X_HEADER_RIGHT_LENGTH) ))
  (( X_PROMPT_SPACER = $COLUMNS - $X_PROMPTS_WIDTH ))
  if [[ "$X_PROMPTS_WIDTH" -ge $COLUMNS ]]; then
    X_PRINT_RIGHT=""
  else
    X_PRINT_RIGHT="${(l:$X_PROMPT_SPACER:)}${X_HEADER_RIGHT}"
  fi
  print -rP - "${X_HEADER_LEFT}${X_PRINT_RIGHT}"
}

prompt_custom_precmd() {
  vcs_info
}

prompt_custom_setup() {
  autoload -Uz vcs_info
  #add-zsh-hook precmd prompt_custom_precmd
  #add-zsh-hook precmd prompt_custom_header_date
  #add-zsh-hook precmd prompt_custom_header
  prompt_opts=( cr percent sp )
  PS1='%F{white}%#%f '
}

#prompt_custom_setup "$@"

function _reset-prompt-and-accept-line {
  prompt_custom_header_rewrite_date
  zle .accept-line
}
#zle -N accept-line _reset-prompt-and-accept-line

function _reset-prompt-and-accept-isearch {
  prompt_custom_header_rewrite_date
  zle .zle-isearch-exit
}
#zle -N zle-isearch-exit _reset-prompt-and-accept-isearch

zmodload zsh/datetime
autoload -U promptinit
#autoload -U history-search-end

#zle -N history-beginning-search-backward-end history-search-end
#zle -N history-beginning-search-forward-end history-search-end
#bindkey "^[[A" history-beginning-search-backward-end
#bindkey "^[[B" history-beginning-search-forward-end
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down


# Paths
[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Completion
#command -v gt > /dev/null 2>&1 && eval "$(gt completion)"
#command -v devbox > /dev/null 2>&1 && eval "$(devbox completion zsh)"

local HOMESHICK="$HOME/.homesick/repos/homeshick"
if [ -d "$HOMESHICK" ]; then
  echo "Loading homeshick"
  source "$HOMESHICK/homeshick.sh"
  homeshick --quiet refresh
  fpath=($HOMESHICK/completions $fpath)
fi

zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"/zsh/zcompcache
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-$ZSH_VERSION

# Tools
command -v direnv > /dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v starship > /dev/null 2>&1 && eval "$(starship init zsh)"
