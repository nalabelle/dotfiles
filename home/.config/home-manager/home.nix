{ pkgs, ... }:

{
  home.username = "nalabelle";
  home.homeDirectory = "/home/nalabelle";
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    # General shell
    curl
    fzf
    jq
    tmux
    vim
    wget
    zsh

    # Environment
    direnv
    nix
    nix-direnv

    # Dev Tools
    ctags
    earthly
    git
    gnumake
    mkcert
    podman
    pre-commit

    # Kubernetes
    fluxcd
    k9s
    krew
    kubectl
    kyverno
  ];

  programs.home-manager.enable = true;
}

