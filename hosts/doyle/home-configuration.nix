# Doyle desktop/gaming PC user packages
{
  pkgs,
  ...
}:
{
  home.packages =
    (with pkgs; [
      # Desktop
      brave
      btop
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
      opencode
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
    ])
    ++ [
      (pkgs.callPackage ../../nix/pkgs/vintagestory { })
    ];

  # Enable MangoHud overlay for all supported games
  # Toggle in-game with Shift+F12
  home.sessionVariables = {
    # Enable per-game with mangohud %command%
    #MANGOHUD = "1";
  };
}
