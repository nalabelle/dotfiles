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

    # Kubernetes
    k9s
    krew
    kubectl
  ];

  programs.home-manager.enable = true;
}

