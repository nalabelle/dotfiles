{ pkgs, ... }:

{
  home.username = "nalabelle";
  home.stateVersion = "23.11";

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
    glow

    # Fancy Prompt
    starship

    # Environment
    direnv
    nix
    nix-direnv

    # Dev Tools
    universal-ctags
    git
    gnumake
    podman
    pre-commit
    cargo
    gh

    devbox
    convco

    # Kubernetes
    k9s
    krew
    kubectl

    # tools
    sqlite

    # General Linters/Fixers
    vale
    markdownlint-cli
  ];

  programs.home-manager.enable = true;
}

