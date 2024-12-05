{ pkgs, ... }:
{
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

    # Fancy Prompt
    starship

    # Environment
    direnv
    nix
    nix-direnv

    # Dev
    git
    cargo
    gh
    devbox
    convco

    # Kubernetes/Containers
    podman
    docker-compose

    # Tools
    sqlite

    # Viewers
    glow
  ];

  programs.home-manager.enable = true;
}

