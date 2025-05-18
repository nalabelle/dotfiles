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
      "android-ndk"
      "android-platform-tools"
      "android-studio"
      "docker" # docker-desktop
      "kopiaui"
      "syncthing"
    ];

    masApps = { Tailscale = 1475387142; };
  };
}
