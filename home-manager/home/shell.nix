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
