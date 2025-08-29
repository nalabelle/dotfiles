{ pkgs, username, ... }:
{

  nixpkgs.config.allowUnfree = true;
  nix = {
    settings.trusted-users = [ username ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  environment.systemPackages = [ pkgs.home-manager ];
}
