{
  description = "Git template development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "github:nalabelle/dotfiles";
      #url = "path:../..";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # unfree documentation
  #  {
  #    description = "Description for the project";
  #
  #    inputs = {
  #      flake-parts.url = "github:hercules-ci/flake-parts";
  #      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  #    };
  #
  #    outputs = inputs@{ flake-parts, nixpkgs, ... }:
  #      flake-parts.lib.mkFlake { inherit inputs; } {
  #        systems = [ "x86_64-linux" "aarch64-darwin" ];
  #        perSystem = { pkgs, system, ... }: {
  #          # This sets `pkgs` to a nixpkgs with allowUnfree option set.
  #          _module.args.pkgs = import nixpkgs {
  #            inherit system;
  #            config.allowUnfree = true;
  #          };
  #
  #          packages.default = pkgs.hello-unfree;
  #        };
  #      };
  #  }

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        (import inputs.dotfiles.flakeModules.pre-commit { inherit inputs; })
      ];

      perSystem =
        { config, pkgs, ... }:
        {
          pre-commit.settings.hooks = {
            # custom settings here, if any
          };
          devShells.default = pkgs.mkShell {
            inputsFrom = [ config.pre-commit-defaults.devShell ];
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
