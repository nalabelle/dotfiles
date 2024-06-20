{ pkgs, ... }:

{
  home.username = "nalabelle";
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    # General shell
    curl
    fzf
    htop
    jq
    tmux
    vim
    wget

    # Fancy Prompt
    starship

    # Environment
    direnv
    nix
    nix-direnv

    # Dev Tools
    ctags
    git
    gnumake
    podman
    pre-commit

    devbox
    devenv
    convco

    # Kubernetes
    k9s
    krew
    kubectl

    # tools
    sqlite
  ];

  programs.home-manager.enable = true;
}

