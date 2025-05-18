{ pkgs, system, flakeInputs, ... }: {
  nixpkgs.config.allowUnfree =
    true; # Allow unfree packages globally for this system

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
  };
  environment.systemPackages =
    [ flakeInputs.home-manager.packages.${pkgs.system}.default ];
  system = {
    stateVersion = 6;
    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts.postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

      # Set 24-hour clock on login. The "global system" setting below only applies to user clock I guess?
      sudo defaults write /Library/Preferences/.GlobalPreferences.plist AppleICUForce24HourTime -bool true

      # Attempt to disable Homebrew analytics
      if [ -x "/opt/homebrew/bin/brew" ]; then
        echo "Attempting to disable Homebrew analytics..."
        /opt/homebrew/bin/brew analytics off
      fi
    '';

    defaults = {
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
      # Added from modules/macos/default.nix
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
        # Added from modules/macos/default.nix
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
}
