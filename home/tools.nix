{ config, lib, pkgs, system ? builtins.currentSystem, ... }: {
  home.packages = with pkgs; [
    # Dev tools
    act
    gh
    git-lfs
    devbox
    convco
    mkcert
    _1password-cli
    copier

    # Environment
    direnv
    nix-direnv

    # Kubernetes/Containers
    docker-compose

    # Tools
    sqlite
    # I wish psql came separate
    postgresql
    wakeonlan
    rsync

    # Viewers
    glow

    qdrant
    ollama

    # Custom scripts
    (writeShellApplication {
      name = "nix-refresh";
      runtimeInputs = [ home-manager git ];
      text = builtins.readFile ../bin/nix-refresh;
    })
    (writeShellApplication {
      name = "dff";
      runtimeInputs = [ coreutils ];
      text = builtins.readFile ../bin/dff;
    })
    (writeShellApplication {
      name = "find-and-replace";
      runtimeInputs = [ findutils gnused ];
      text = builtins.readFile ../bin/find-and-replace;
    })
    (writeShellApplication {
      name = "status-getcpu";
      runtimeInputs = [ procps ];
      text = builtins.readFile ../bin/status-getcpu;
    })
    (writeShellApplication {
      name = "status-getload";
      runtimeInputs = [ procps ];
      text = builtins.readFile ../bin/status-getload;
    })
  ];

  # Containers configuration
  xdg.configFile."containers/policy.json".text = ''
    {
        "default": [
            {
                "type": "insecureAcceptAnything"
            }
        ],
        "transports": {
            "docker-daemon": {
                "": [{"type":"insecureAcceptAnything"}]
            }
        }
    }
  '';

  # Curl configuration
  home.file.".curlrc".text = ''
    progress-bar
  '';

  # MySQL configuration
  home.file.".my.cnf".text = ''
    [mysql]
    prompt=T\\R:\\m:\\s\\S\\_\\"\\h\\" [\\d]>\\_
    show-warnings
    auto-rehash
  '';

  programs.poetry = {
    enable = true;
    # this is installed per project
    package = null;
    settings = { virtualenvs = { in-project = true; }; };
  };

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

  # Devbox completion (co-located with devbox installation)
  programs.zsh.initContent = lib.mkAfter ''
    if command -v devbox > /dev/null 2>&1; then
      eval "$(devbox completion zsh)"
    fi
  '';

}
