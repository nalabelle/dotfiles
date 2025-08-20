{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./colors.nix
    ./git.nix
    ./tmux.nix
    ./tools.nix
    ./vim.nix
    ./vscode.nix
    ./zsh.nix
    ./darwin.nix
    ./shell.nix
    ./fonts.nix
  ];

  home.stateVersion = "24.11";

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
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      frequency = "weekly";
      options = "--delete-older-than 30d";
      persistent = true;
    };
  };

  xdg = {
    enable = true;
  };

  # Prefer XDG directories for consistency with the rest of the configuration
  home.preferXdgDirectories = true;
}
