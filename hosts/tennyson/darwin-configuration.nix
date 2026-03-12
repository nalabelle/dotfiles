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
    (pkgs.callPackage ../../packages/kilocode-cli.nix { })
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
  };

  # Automatic file cleanup service for Downloads and Screenshots directories
  launchd.user.agents.file-cleaner =
    let
      cleanerPkg = pkgs.callPackage ../../packages/cleaner.nix { };
      fileCleanerScript = pkgs.writeShellScriptBin "file-cleaner-wrapper" ''
        set -eu
        set -o pipefail
        set -x
        ${cleanerPkg}/bin/cleaner --not-modified-within 3d "/Users/${username}/Downloads"
        ${cleanerPkg}/bin/cleaner --not-modified-within 7d "/Users/${username}/Screenshots"
      '';
    in
    {
      serviceConfig = {
        Label = "org.nixos.file-cleaner";
        Program = "${fileCleanerScript}/bin/file-cleaner-wrapper";
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
