{ pkgs, system, ... }: {
  # Tennyson-specific configuration

  # Enable Homebrew
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    # Disable analytics
    extraConfig = ''
      exec "/opt/homebrew/bin/brew analytics off"
    '';

    # Install Docker Desktop as a cask
    casks = [
      "docker" # This installs Docker Desktop for macOS
    ];
  };
}
