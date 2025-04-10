{ pkgs, config, ... }: {
  # https://home-manager-options.extranix.com/?query=&release=release-24.11
  home.username = "nalabelle";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # General shell
    curl
    fzf
    ripgrep
    htop
    bat
    jq
    tmux
    vim-full
    wget

    # ZSH
    zsh-syntax-highlighting
    zsh-history-substring-search
    zsh-autosuggestions

    # Fancy Prompt
    starship

    # Environment
    direnv
    nix-direnv

    # Dev
    act
    git
    #cargo
    #cargo-binstall
    gh
    devbox
    devenv
    convco

    # Kubernetes/Containers
    docker-compose

    # Tools
    sqlite

    # Viewers
    glow
  ];

  nix.gc = {
    automatic = true;
    frequency = "weekly";
    options = "--delete-older-than 30d";
    persistent = true;
  };

  xdg = { enable = true; };

  programs.home-manager.enable = true;

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

    historySubstringSearch = { enable = true; };
    autosuggestion = { enable = true; };
    syntaxHighlighting = { enable = true; };

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

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };
}

