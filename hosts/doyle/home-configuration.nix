# Doyle desktop/gaming PC user packages
{
  pkgs,
  nix-flatpak,
  lib,
  ...
}:

let
  opencode-wrappers = pkgs.callPackage ../../nix/pkgs/opencode-wrappers.nix { };
in

{
  imports = [ nix-flatpak.homeManagerModules.nix-flatpak ];

  services.flatpak = {
    enable = true;
    remotes = lib.mkDefault [
      {
        name = "vintagestory";
        location = "https://flatpak.vintagestory.at/VintageStory.flatpakrepo";
      }
    ];
    packages = [
      {
        appId = "at.vintagestory.VintageStory";
        origin = "vintagestory";
      }
      {
        appId = "at.vintagestory.VintageStory.Unstable";
        origin = "vintagestory";
      }
    ];
  };

  home.packages =
    (with pkgs; [
      # Desktop
      brave
      btop
      gearlever # AppImage manager with desktop integration and auto-updates
      obs-studio
      obsidian
      kopia-ui
      syncthing
      syncthingtray
      onlyoffice-desktopeditors

      # KDE
      kdePackages.konsole
      kdePackages.dolphin

      # Wine
      wineWow64Packages.stable
      winetricks

      # Code
      zed-editor

      # Media
      feishin
      fooyin
      puddletag
      supersonic
      vlc

      # Gaming utilities
      mangohud # Performance monitoring overlay (FPS, temps, etc.)
      goverlay # GUI for configuring MangoHud and other overlays
      gamemode # CLI tools for gamemode

      # Game launchers and managers
      lutris # Multi-platform game launcher (Steam, Epic, GOG, etc.)
      heroic # Epic Games Store and GOG launcher
      (bottles.override { removeWarningPopup = true; }) # Wine prefix manager with modern UI

      # Communication
      discord # Voice and text chat for gaming
      webcord
      signal-desktop

      # Diagnostics
      libva-utils # vainfo - check VA-API status
      vdpauinfo # check VDPAU status

      # CIFS mount helper script
      # Usage: mount-cifs //server/share /path/to/mountpoint
      (writeShellScriptBin "mount-cifs" ''
        set -euo pipefail

        # Usage information
        usage() {
          echo "Usage: mount-cifs <//server/share> <mountpoint>"
          echo ""
          echo "Mount a CIFS/SMB share with your uid/gid and credentials from /run/agenix/nalabelleSmbCredentials"
          echo ""
          echo "Examples:"
          echo "  mount-cifs //chaucer/media ~/mnt/media"
          echo "  mount-cifs //192.168.1.100/backup /mnt/backup"
          exit 1
        }

        # Check arguments
        if [ $# -ne 2 ]; then
          usage
        fi

        SHARE="$1"
        MOUNTPOINT="$2"
        CREDS_FILE="/run/agenix/nalabelleSmbCredentials"

        # Check if credentials file exists
        if [ ! -f "$CREDS_FILE" ]; then
          echo "Error: Credentials file not found at $CREDS_FILE"
          exit 1
        fi

        # Create mountpoint if it doesn't exist
        mkdir -p "$MOUNTPOINT"

        # Get uid and gid
        MOUNT_UID=$(id -u)
        MOUNT_GID=$(id -g)

        # Mount the share
        echo "Mounting $SHARE to $MOUNTPOINT..."
        sudo ${cifs-utils}/bin/mount.cifs "$SHARE" "$MOUNTPOINT" \
          -o "credentials=$CREDS_FILE,uid=$MOUNT_UID,gid=$MOUNT_GID,file_mode=0644,dir_mode=0755"

        echo "Successfully mounted $SHARE at $MOUNTPOINT"
      '')

    ])
    ++ [
      opencode-wrappers.opencode-wrapped
    ];

  # Enable MangoHud overlay for all supported games
  # Toggle in-game with Shift+F12
  home.sessionVariables = {
    # Enable per-game with mangohud %command%
    #MANGOHUD = "1";
  };
}
