{ pkgs, system, ... }: {
  # Tennyson-specific configuration

  # Enable Homebrew
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
      extraFlags = [ "--verbose" ];
    };

    casks = [
      "docker" # This installs Docker Desktop for macOS
      "kopiaui"
      "syncthing"
    ];
  };
}
