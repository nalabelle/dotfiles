{ config, lib, pkgs, ... }:

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
    less
  ];

  nix.gc = {
    automatic = true;
    frequency = "weekly";
    options = "--delete-older-than 30d";
    persistent = true;
  };

  xdg = { enable = true; };

  programs.home-manager.enable = true;
}
