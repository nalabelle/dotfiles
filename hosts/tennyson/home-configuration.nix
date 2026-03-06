{
  pkgs,
  lib,
  ...
}:

let
  kilocode-cli = pkgs.callPackage ../../nix/pkgs/kilocode-cli.nix { };
in
{
  home.packages = [
    kilocode-cli
  ];
}
