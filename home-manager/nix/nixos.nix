{ pkgs, ... }: {

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [ pkgs.home-manager pkgs.zsh ];
}
