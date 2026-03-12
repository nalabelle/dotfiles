{
  lib,
  pkgs,
  ...
}:

{
  services.home-manager = {
    autoExpire = {
      enable = true;
      frequency = "weekly";
      timestamp = "-30 days";
    };
    autoUpgrade = {
      enable = true;
      frequency = "weekly";
    };
  };

  # Nix package manager settings (Linux only - Determinate Nix handles this on Darwin)
  nix = {
    enable = true;
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
      persistent = true;
    };
  };
}
