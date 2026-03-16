{
  pkgs,
  lib,
  ...
}:

let
  opencode-wrappers = pkgs.callPackage ../../nix/pkgs/opencode-wrappers.nix { };
in
{
  home.packages = [
    opencode-wrappers.opencode-wrapped
  ];
}
