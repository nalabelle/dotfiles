{ config, lib, pkgs, ... }:

{
  imports = [
    ./git.nix
    ./tmux.nix
    ./tools.nix
    ./zsh.nix
    ./darwin.nix
    ./shell.nix
    ./fonts.nix
  ];

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
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

  programs.home-manager.enable = true;
  services.home-manager = lib.mkIf pkgs.stdenv.isLinux {
    autoExpire = {
      enable = true;
      frequency = "weekly";
      timestamp = "-30 days";
    };
    autoUpgrade = {
      enable = true;
      frequency = "weekly";
    };
  };

  nix = {
    enable = true;
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      frequency = "weekly";
      options = "--delete-older-than 30d";
      persistent = true;
    };
  };

  xdg = { enable = true; };
}
