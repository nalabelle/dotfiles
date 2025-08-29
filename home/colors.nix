{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Configure dircolors using Home Manager's built-in support
  programs.dircolors = {
    enable = true;
    # Enable automatic shell integration
    enableBashIntegration = true;
    enableZshIntegration = true;
    # Reference the existing dircolors file directly
    extraConfig = builtins.readFile ../config/dircolors;
  };

  # Consistent colored command aliases using Nix packages
  home.shellAliases = {
    # Use GNU tools consistently for color support
    ls = "${pkgs.coreutils}/bin/ls --color=always";
    grep = "${pkgs.gnugrep}/bin/grep --color=always";
    diff = "${pkgs.diffutils}/bin/diff --color=always";
    less = "${pkgs.less}/bin/less -R";
  };

  # Shell functions for colored man pages
  programs.bash.initExtra = lib.mkAfter ''
    # Colored man pages function
    man() {
      env LESS_TERMCAP_mb="$(printf "\001\033[1;31m\002")" \
          LESS_TERMCAP_md="$(printf "\001\033[1;31m\002")" \
          LESS_TERMCAP_me="$(printf "\001\033[0m\002")" \
          LESS_TERMCAP_se="$(printf "\001\033[0m\002")" \
          LESS_TERMCAP_so="$(printf "\001\033[1;44;33m\002")" \
          LESS_TERMCAP_ue="$(printf "\001\033[0m\002")" \
          LESS_TERMCAP_us="$(printf "\001\033[1;32m\002")" \
          command man "$@"
    }
  '';

  # Zsh-specific configuration for completion colors
  programs.zsh = lib.mkIf config.programs.zsh.enable {
    initContent = lib.mkAfter ''
      # Colored man pages function
      man() {
        env LESS_TERMCAP_mb="$(printf "\001\033[1;31m\002")" \
            LESS_TERMCAP_md="$(printf "\001\033[1;31m\002")" \
            LESS_TERMCAP_me="$(printf "\001\033[0m\002")" \
            LESS_TERMCAP_se="$(printf "\001\033[0m\002")" \
            LESS_TERMCAP_so="$(printf "\001\033[1;44;33m\002")" \
            LESS_TERMCAP_ue="$(printf "\001\033[0m\002")" \
            LESS_TERMCAP_us="$(printf "\001\033[1;32m\002")" \
            command man "$@"
      }

      # Set zsh completion colors to match dircolors
      # Note: LS_COLORS is set by Home Manager's enableZshIntegration
      if [[ -n "$LS_COLORS" ]]; then
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      fi
    '';
  };

  # Ensure we have the tools we need for consistent color support
  home.packages = with pkgs; [
    coreutils # Provides ls with consistent --color support
    gnugrep # Provides grep with --color support
    diffutils # Provides diff with --color support
    less # Provides less with -R color support
  ];
}
