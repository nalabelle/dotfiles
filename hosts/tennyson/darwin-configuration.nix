{ pkgs, inputs, hostname, username, ... }: {
  homebrew = {
    casks = [
      "android-ndk"
      "android-platform-tools"
      "android-studio"
      "balenaetcher"
      "calibre"
      "foobar2000"
      "kopiaui"
      "mountain-duck"
      "obsidian"
      "onlyoffice"
      "protonvpn"
      "zed"
    ];
  };

  # Aggressive Nix garbage collection and safe store optimization
  nix = {
    # 1) GC configuration: disable built-in scheduler; use custom launchd agent below
    gc = { automatic = false; };

    # 2) Safe store optimization via nix-darwin
    optimise.automatic = true;

    # 3) Disable keep-outputs and keep-derivations to enable more aggressive GC
    extraOptions = ''
      keep-outputs = false
      keep-derivations = false
    '';
  };

  # Configure the Nix garbage collection service with additional options
  launchd.user.agents.nix-gc = {
    serviceConfig = {
      ProgramArguments = [
        "/run/current-system/sw/bin/nix-collect-garbage"
        "--delete-older-than"
        "7d"
      ];
      RunAtLoad = true; # Run at login if missed
      KeepAlive = false; # Don't restart after completion
      StartCalendarInterval = [{
        Weekday = 1; # Monday
        Hour = 3; # 3 AM
        Minute = 0; # On the hour
      }];
      ProcessType = "Background";
      Nice = 19; # Lowest priority
      LowPriorityIO = true; # Reduce I/O priority
      TimeOut = 3600; # Hard kill if GC exceeds 1 hour
      StandardOutPath = "/Users/${username}/.local/var/log/nix-gc.log";
      StandardErrorPath = "/Users/${username}/.local/var/log/nix-gc.log";
    };
  };
}
