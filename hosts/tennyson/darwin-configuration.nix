{
  pkgs,
  inputs,
  hostname,
  username,
  lib,
  ...
}:
{
  # Add OpenZFS binaries to PATH
  environment.systemPath = lib.mkAfter [
    "/usr/local/zfs/bin"
  ];
  # ZFS snapshot replication tools
  environment.systemPackages = with pkgs; [
    pv # Progress monitoring for transfers
  ];

  homebrew = {
    casks = [
      "1password"
      "android-ndk"
      "android-platform-tools"
      "android-studio"
      "archivewebpage"
      "balenaetcher"
      "brave-browser"
      "caldigit-docking-utility"
      "calibre"
      "coconutbattery"
      "connectmenow"
      "element"
      "forecast"
      "gimp"
      "iterm2"
      "keepassxc"
      "kopiaui"
      "linearmouse"
      "logitune" # Needs manual install
      "mountain-duck"
      "musicbrainz-picard"
      "obs"
      "obsidian"
      "onlyoffice"
      "openzfs"
      "orbstack"
      "plexamp"
      "protonvpn"
      "raycast"
      "replaywebpage"
      "swinsian"
      "syncthing-app"
      "tailscale-app"
      "visual-studio-code"
      "vlc"
      "winbox"
      "wireshark-app"
      "zed"
      "zoom"
    ];
    taps = [
      "sst/tap"
    ];
    brews = [
      "sst/tap/opencode"
    ];
  };

  # Aggressive Nix garbage collection and safe store optimization
  nix = {
    # 1) GC configuration: disable built-in scheduler; use custom launchd agent below
    gc = {
      automatic = false;
    };

    # 2) Safe store optimization via nix-darwin
    optimise.automatic = true;

    # 3) Disable keep-outputs and keep-derivations to enable more aggressive GC
    extraOptions = ''
      keep-outputs = false
      keep-derivations = false
    '';

    # 4) Trust binary caches used by infra flake (nix-community, numtide, fufexan)
    #    Without these in nix.conf, flake nixConfig substituters are ignored unless
    #    --accept-flake-config is passed, causing source builds with test failures.
    settings = {
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://numtide.cachix.org"
        "https://fufexan.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfcKWR9ISIFy5curUsY="
      ];
    };
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
      StartCalendarInterval = [
        {
          Hour = 3; # 3 AM
          Minute = 0; # On the hour
        }
      ];
      ProcessType = "Background";
      Nice = 19; # Lowest priority
      LowPriorityIO = true; # Reduce I/O priority
      TimeOut = 3600; # Hard kill if GC exceeds 1 hour
      StandardOutPath = "/Users/${username}/.local/var/log/nix-gc.log";
      StandardErrorPath = "/Users/${username}/.local/var/log/nix-gc.log";
    };
  };

  # Automatic file cleanup service for Downloads and Screenshots directories
  launchd.user.agents.file-cleaner =
    let
      cleanerPkg = pkgs.callPackage ../../packages/cleaner.nix { };
    in
    {
      serviceConfig = {
        Label = "org.nixos.file-cleaner";
        ProgramArguments = [
          "/bin/sh"
          "-c"
          ''
            set -eu
            set -o pipefail
            set -x
            # Clean Downloads directory (files older than 3 days)
            ${cleanerPkg}/bin/cleaner --not-modified-within 3d "/Users/${username}/Downloads"

            # Clean Screenshots directory (files older than 1 week)
            ${cleanerPkg}/bin/cleaner --not-modified-within 7d "/Users/${username}/Screenshots"
          ''
        ];
        RunAtLoad = true; # Run at login if scheduled time was missed
        KeepAlive = false;
        StartCalendarInterval = [
          {
            Hour = 3; # 3 AM
            Minute = 0; # On the hour
          }
        ];
        ProcessType = "Background";
        Nice = 10; # Lower priority than normal processes
        LowPriorityIO = true;
        TimeOut = 1800; # 30 minute timeout to prevent hanging
        StandardOutPath = "/Users/${username}/Library/Logs/cleaner.log";
        StandardErrorPath = "/Users/${username}/Library/Logs/cleaner.log";
      };
    };
}
