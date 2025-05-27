{ config, lib, pkgs, ... }:

{
  # Environment variables from .profile that aren't already handled by other modules
  home.sessionVariables = {
    # Core environment variables
    LANG = "en_US.UTF-8";
    EDITOR = "vim";
    PAGER = "less";

    # Less configuration
    LESSHISTSIZE = "0";

    # Vi mode configuration (remove escape lag)
    KEYTIMEOUT = "1";
  };

  # Readline configuration
  programs.readline = {
    enable = true;
    includeSystemConfig = true;
    extraConfig = ''
      set editing-mode vi
      set show-mode-in-prompt on

      $if Bash
        set vi-ins-mode-string \001\e[6 q\e[38;5;14m\002+\001\e[0m\002
        set vi-cmd-mode-string \001\e[2 q\e[38;5;13m\002!\001\e[0m\002
      $else
        set vi-ins-mode-string \1\e[2 q\e[0m\2
        set vi-cmd-mode-string \1\e[6 q\e[0m\2
      $endif

      # Color files by types
      set colored-stats On
      # Append char to indicate type
      set visible-stats On
      # Mark symlinked directories
      set mark-symlinked-directories On

      # Color the common prefix
      set colored-completion-prefix On
      # Show completions on first tab
      set show-all-if-ambiguous On
      # Turn off case sensitivity for completion
      set completion-ignore-case On
      # Color the common prefix in menu-complete
      set menu-complete-display-prefix On

      # Vi command mode key bindings
      set keymap vi-command
      "k": history-search-backward
      "j": history-search-forward
    '';
  };

  # Configure bash
  programs.bash = {
    enable = true;
    initExtra = ''
      # Set file descriptor limit (from .profile)
      ulimit -n 10240
    '';
  };

  # Configure zsh ulimit (this will be merged with existing zsh config)
  programs.zsh.initContent = lib.mkBefore ''
    # Set file descriptor limit (from .profile)
    ulimit -n 10240
  '';
}
