{
  pkgs,
  lib,
  ...
}:

let
  opencode-cli = pkgs.callPackage ../../nix/pkgs/opencode-cli.nix { };
  kilocode-cli = pkgs.callPackage ../../nix/pkgs/kilocode-cli.nix { };
in
{
  home.packages = [
    opencode-cli
    kilocode-cli
  ];
}
