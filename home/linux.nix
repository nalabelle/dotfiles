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
    # DO NOT enable autoUpgrade on hosts managed via the NixOS home-manager module
    # (inputs.home-manager.nixosModules.home-manager). The autoUpgrade service runs
    # `home-manager switch` as a standalone tool using nix channels, which conflicts
    # with NixOS-module-managed generations and corrupts the home-manager config on
    # every reboot (the timer is Persistent=true). Updates happen via nixos-rebuild /
    # make deploy-<host> instead.
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
