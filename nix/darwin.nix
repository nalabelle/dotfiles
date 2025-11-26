{
  pkgs,
  config,
  lib,
  hostname,
  username,
  ...
}:
{
  # System-wide Zsh configuration
  programs.zsh = {
    enable = true; # Enable system Zsh (creates proper /etc/zshrc)
    enableGlobalCompInit = false; # Don't call compinit (let user control it)

    # Add completions to fpath for all users
    # Completions match installation scope: system-wide apps get system-wide completions
    shellInit = ''
      # Homebrew completions
      if [ -d /opt/homebrew/share/zsh/site-functions ]; then
        fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
      fi

      # OrbStack completions (includes _docker, _kubectl that aren't symlinked by cask)
      if [ -d /Applications/OrbStack.app/Contents/Resources/completions/zsh ]; then
        fpath=(/Applications/OrbStack.app/Contents/Resources/completions/zsh $fpath)
      fi
    '';
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.computerName = hostname;
  networking.hostName = hostname;
  users.users."${username}".home = "/Users/${username}";

  environment.systemPackages = [
    # Upgrade ancient osx bash
    pkgs.bash
    (pkgs.callPackage ../packages/peazip.nix { })
  ];
  environment.systemPath = lib.mkBefore [
    # User-specific Nix profiles (needed for GUI applications)
    # When useUserPackages = true: packages managed by nix-darwin in /etc/profiles/per-user/
    # Note for system setup: root is in /nix/var/nix/profiles/per-user/root
    # When useUserPackages = false: packages managed by user in ~/.nix-profile
    # Since this is a darwin setup, we'll pick the etc version
    "/etc/profiles/per-user/${username}/bin"
    # Homebrew paths
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
  };

  system = {
    stateVersion = 6;
    primaryUser = username;

    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    # Only preActivation, extraActivation, and postActivation can be customized.
    activationScripts.postActivation.text = ''
      echo "Running custom darwin activation script for user: ${username}"

      # Set 24-hour clock on login. The "global system" setting below only applies to user clock I guess?
      echo "Setting 24-hour clock format..."
      defaults write /Library/Preferences/.GlobalPreferences.plist AppleICUForce24HourTime -bool true

      # Attempt to disable Homebrew analytics
      if [ -x "/opt/homebrew/bin/brew" ]; then
        echo "Attempting to disable Homebrew analytics..."
        sudo -u ${username} HOME="/Users/${username}" /opt/homebrew/bin/brew analytics off
      fi

      # Create the Screenshots directory if it doesn't exist
      mkdir -p "/Users/${username}/Screenshots"
      # Set ownership to the user
      chown "${username}:staff" "/Users/${username}/Screenshots"

      # Global PATH for GUI applications launched from Finder
      # Uses nix-darwin's systemPath which includes:
      # - User-specific Nix profiles (/Users/${username}/.nix-profile/bin, per-user profiles)
      # - Homebrew paths (/opt/homebrew/bin, /opt/homebrew/sbin)
      # - System packages (/run/current-system/sw/bin)
      # - Default Nix profile (/nix/var/nix/profiles/default/bin)
      # - Standard system paths (/usr/local/bin, /usr/bin, etc.)
      #
      # Sources:
      #  https://stackoverflow.com/questions/51636338/what-does-launchctl-config-user-path-do/70510488
      #  https://apple.stackexchange.com/questions/51677/how-to-set-path-for-finder-launched-applications/198282
      #
      # Debugging commands:
      # - Query current custom PATH: launchctl getenv PATH
      # - Query default system PATH: sysctl -n user.cs_path
      #
      echo "Setting GUI application PATH: ${config.environment.systemPath}"
      launchctl config user path "${config.environment.systemPath}"

      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      #echo "Activating system settings..."
      #/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      smb.NetBIOSName = hostname;
      menuExtraClock.Show24Hour = true;
      menuExtraClock.ShowAMPM = false;
      # Disable "windows move aside when clicking on desktop" feature
      WindowManager.EnableStandardClickToShowDesktop = false;
      dock = {
        show-recents = false;
        autohide = true;
        magnification = true;
        # most recently used spaces
        mru-spaces = false;
        tilesize = 32;
        largesize = 64;
        # Hot corner configuration
        wvous-br-corner = 13; # Bottom right corner - Lock Screen
      };
      NSGlobalDomain = {
        AppleICUForce24HourTime = true;
        AppleShowAllExtensions = true;
        "com.apple.trackpad.forceClick" = false;
        ApplePressAndHoldEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
      };
      finder = {
        FXPreferredViewStyle = "Nlsv";
        FXRemoveOldTrashItems = true;
        ShowStatusBar = true;
        _FXSortFoldersFirst = true;
        FXDefaultSearchScope = "SCcf";
        NewWindowTarget = "Home";
      };
      screencapture = {
        location = "/Users/${username}/Screenshots";
        # Other options:
        # type = "png"; # jpg, tiff, pdf, bmp
        # disable-shadow = true;
      };

      controlcenter = {
        BatteryShowPercentage = true;
      };
      CustomUserPreferences = {
        ".GlobalPreferences" = {
          AppleFirstWeekday = {
            gregorian = 2;
          };
          AppleICUDateFormatStrings = {
            "1" = "yyyy-MM-dd"; # Short date format
            "2" = "yyyy-MM-dd"; # Medium date format
            "3" = "dd MMM y"; # Long date format
            "4" = "EEEE, dd MMMM y"; # Extra long date format
          };
        };

        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };

  # Enable Homebrew and configure it based on the current machine
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
      extraFlags = [ "--verbose" ];
    };

    casks = [
      "1password"
      "brave-browser"
      "caldigit-docking-utility"
      "coconutbattery"
      "docker-desktop"
      "iterm2"
      "logitune" # Needs manual install
      "plexamp"
      "raycast"
      "syncthing-app"
      "tailscale-app"
      "unnaturalscrollwheels"
      "visual-studio-code"
    ];
  };

}
