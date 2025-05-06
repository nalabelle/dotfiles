{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    zsh-syntax-highlighting
    zsh-history-substring-search
    zsh-autosuggestions
  ];

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    autocd = true;
    enableCompletion = true;
    envExtra = ''
      skip_global_compinit=1
    '';

    # History
    history = {
      path = "${config.xdg.stateHome}/zsh/history";
      # How many commands in the history file
      save = 5000;
      # How many commands in session history
      size = 2000;
      append = true;
      expireDuplicatesFirst = true;
      findNoDups = true;
      ignoreAllDups = true;
      ignoreDups = true;
      share = false;
    };

    historySubstringSearch.enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    completionInit = ''
      zstyle ':completion:*' cache-path ${config.xdg.cacheHome}/zsh/zcompcache
      autoload -Uz compinit
      compinit -d ${config.xdg.cacheHome}/zsh/zcompdump-$ZSH_VERSION
    '';

    initExtraFirst = ''
      source ${config.home.homeDirectory}/.homesick/repos/dotfiles/home/.profile;
    '';

    initExtraBeforeCompInit = ''
      source ${config.home.homeDirectory}/.homesick/repos/dotfiles/zsh/options;
      source ${config.home.homeDirectory}/.homesick/repos/dotfiles/zsh/prompt;
      source ${config.home.homeDirectory}/.homesick/repos/dotfiles/zsh/imports;
    '';

    initExtra = ''
      source ${config.home.homeDirectory}/.homesick/repos/dotfiles/zsh/completions;
    '';
  };
}
