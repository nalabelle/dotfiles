{ pkgs ? import <nixpkgs> { } }:

let
  devEnv = pkgs.mkShell {
    packages = with pkgs; [
      shellcheck
      pre-commit
      shfmt
      nil
      gh
      nixfmt-rfc-style
    ];

    shellHook = ''
      echo "Dev environment loaded with shellcheck, pre-commit, shfmt, nil, gh, and nixfmt"
    '';
  };
in devEnv
