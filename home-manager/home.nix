{ pkgs, ... }:
{
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

    # Fancy Prompt
    starship

    # Environment
    direnv
    nix-direnv

    # Dev
    git
    cargo
    cargo-binstall
    gh
    devbox
    convco

    # Kubernetes/Containers
    docker-compose

    # Tools
    sqlite

    # Viewers
    glow
  ];

  programs.home-manager.enable = true;
}

