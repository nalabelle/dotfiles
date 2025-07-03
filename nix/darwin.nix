{ pkgs, system, flakeInputs, config, lib, vars, hostname, username, ... }: {
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.computerName = hostname;
  networking.hostName = hostname;
  nix = {
    settings.trusted-users = [ username ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  users.users."${username}".home = "/Users/${username}";

  # Upgrade ancient osx bash
  environment.systemPackages = [ pkgs.bash ];

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
      # This must be synchronized with home.sessionPath in home/shell.nix
      #
      # Components (in order of precedence):
      # 1. User's Nix profile (Home Manager packages)
      # 2. Per-user system packages
      # 3. Homebrew packages (/opt/homebrew/bin + /opt/homebrew/sbin)
      # 4. System-wide Nix packages
      # 5. Default Nix profile
      # 6. Standard system paths (/usr/local/bin + default system paths)
      #
      # Sources:
      #  https://stackoverflow.com/questions/51636338/what-does-launchctl-config-user-path-do/70510488
      #  https://apple.stackexchange.com/questions/51677/how-to-set-path-for-finder-launched-applications/198282
      #
      # Debugging commands:
      # - Query current custom PATH: launchctl getenv PATH
      # - Query default system PATH: sysctl -n user.cs_path
      #
      launchctl config user path /Users/${username}/.nix-profile/bin:/etc/profiles/per-user/${username}/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      echo "Activating system settings..."
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      smb.NetBIOSName = hostname;
      menuExtraClock.Show24Hour = true;
      menuExtraClock.ShowAMPM = false;
      dock = {
        show-recents = false;
        autohide = true;
        magnification = true;
        # most recently used spaces
        mru-spaces = false;
        tilesize = 32;
        largesize = 64;
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

      controlcenter = { BatteryShowPercentage = true; };
      CustomUserPreferences = {
        ".GlobalPreferences" = {
          AppleFirstWeekday = { gregorian = 2; };
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
      "plexamp"
      "raycast"
      "syncthing-app"
      "tailscale-app"
      "unnaturalscrollwheels"
    ];
  };

  # User launchd agents for auto-starting services
  #
  # Management commands:
  # - Start: launchctl load ~/Library/LaunchAgents/org.nixos.qdrant.plist
  # - Stop:  launchctl unload ~/Library/LaunchAgents/org.nixos.qdrant.plist
  # - Status: launchctl list | grep qdrant
  # - Logs: tail -f ~/.local/var/log/qdrant.log
  #
  # Same commands apply to ollama (replace 'qdrant' with 'ollama')
  # Services auto-start on login and restart if they crash (KeepAlive = true)
  launchd.user.agents.qdrant = {
    serviceConfig = {
      ProgramArguments = [ "${pkgs.qdrant}/bin/qdrant" "--disable-telemetry" ];
      RunAtLoad = true;
      KeepAlive = true;
      WorkingDirectory = "/tmp";
      StandardOutPath = "/Users/${username}/.local/var/log/qdrant.log";
      StandardErrorPath = "/Users/${username}/.local/var/log/qdrant.log";
      SoftResourceLimits = { NumberOfFiles = 10240; };
      HardResourceLimits = { NumberOfFiles = 10240; };
      EnvironmentVariables = {
        QDRANT__STORAGE__STORAGE_PATH =
          "/Users/${username}/.local/share/qdrant/storage";
        QDRANT__STORAGE__SNAPSHOTS_PATH =
          "/Users/${username}/.local/share/qdrant/snapshots";
        QDRANT__STORAGE__TEMP_PATH =
          "/Users/${username}/.local/share/qdrant/temp";
      };
    };
  };

  launchd.user.agents.ollama = {
    serviceConfig = {
      ProgramArguments = [ "${pkgs.ollama}/bin/ollama" "start" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/Users/${username}/.local/var/log/ollama.log";
      StandardErrorPath = "/Users/${username}/.local/var/log/ollama.log";
      SoftResourceLimits = { NumberOfFiles = 10240; };
      HardResourceLimits = { NumberOfFiles = 10240; };
    };
  };
}
