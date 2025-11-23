{
  description = "Git template development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    dotfiles = {
      url = "github:nalabelle/dotfiles";
      #url = "path:../..";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.dotfiles.flakeModules.pre-commit
      ];

      perSystem =
        { config, pkgs, ... }:
        {
          pre-commit.settings.hooks = {
            # custom settings here, if any
          };

          devShells.default = pkgs.mkShell {
            inputsFrom = [ config.devShells.pre-commit ];
            buildInputs = with pkgs; [
              # additional dependencies
            ];

            shellHook = ''
              echo "Dev environment loaded"
            '';
          };
        };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
}
