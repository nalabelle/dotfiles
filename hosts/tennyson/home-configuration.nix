{
  pkgs,
  lib,
  ...
}:

let
  opencode-cli = pkgs.callPackage ../../nix/pkgs/opencode-cli.nix { };
in
{
  home.packages = [
    opencode-cli
  ];
}
