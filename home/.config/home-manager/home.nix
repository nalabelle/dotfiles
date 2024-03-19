{ pkgs, ... }:

{
  home.username = "nalabelle";
  home.homeDirectory = "/home/nalabelle";
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    git
    curl
    wget
    vim
    tmux
    fzf
    zsh
    direnv
    nix-direnv
    nix
    ctags
    podman
    kubectl
    fluxcd
    krew
    gnumake
    kyverno
    pre-commit
    earthly
  ];

  programs.home-manager.enable = true;
  programs.zsh = {
    enable = false;
    enableCompletion = true;
  };
  programs.direnv = {
    enable = false;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}

