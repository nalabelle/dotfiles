{ config, lib, pkgs, system ? builtins.currentSystem, ... }:

let
  extraNodePackages = import ../../node {
    inherit pkgs system;
    nodejs = pkgs.nodejs_22;
  };
in {
  home.packages = with pkgs; [
    # Dev tools
    act
    git
    gh
    devbox
    devenv
    convco
    extraNodePackages."@anthropic-ai/claude-code"
    _1password-cli

    # Environment
    direnv
    nix-direnv

    # Kubernetes/Containers
    docker-compose

    # Tools
    sqlite

    # Viewers
    glow
  ];

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    config = {
      global = {
        strict_env = true;
        load_dotenv = false;
        warn_timeout = "60s";
        hide_env_diff = true;
      };
    };
  };
}
