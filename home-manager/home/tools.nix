{ config, lib, pkgs, system ? builtins.currentSystem, ... }: {
  home.packages = with pkgs; [
    # Dev tools
    act
    gh
    devbox
    convco
    mkcert
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

    # Custom scripts
    (writeShellApplication {
      name = "nix-refresh";
      runtimeInputs = [ home-manager git ];
      text = builtins.readFile ../bin/nix-refresh;
    })
  ];

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
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

  xdg.configFile = {
    "mcpm/config.json".source = ../config/mcpm/config.json;
    "mcpm/profiles.json".source = ../config/mcpm/profiles.json;
  };
}
