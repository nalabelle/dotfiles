{ lib, pkgs, config, vars, system, ... }:

{
  imports = [ ./base.nix ./shell ./terminal ./dev ];

  # Set the home directory conditionally,
  # which is needed for standalone home-manager switch.
  # config.home.username will be correctly substituted by Home Manager.
  home.homeDirectory = if pkgs.stdenv.isDarwin then
    "/Users/${vars.username}"
  else if pkgs.stdenv.isLinux then
    "/home/${vars.username}"
  else
    throw "Unsupported system for home.homeDirectory in modules/default.nix";
}
