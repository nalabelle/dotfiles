{ pkgs ? import <nixpkgs> {} }:

let
  devEnv = pkgs.mkShell {
    packages = with pkgs; [
      shellcheck
      pre-commit
    ];

    shellHook = ''
      echo "Dev environment loaded with shellcheck and pre-commit"
    '';
  };
in
devEnv
