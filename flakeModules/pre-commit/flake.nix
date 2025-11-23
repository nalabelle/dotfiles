{
  description = "Pre-commit hooks flake module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jumanjihouse-hooks = {
      url = "github:jumanjihouse/pre-commit-hooks";
      flake = false;
    };
  };

  outputs =
    inputs@{ git-hooks, jumanjihouse-hooks, ... }:
    {
      flakeModule =
        { lib, flake-parts-lib, ... }:
        {
          config._module.args.jumanjihouse-hooks = jumanjihouse-hooks;
          imports = [
            git-hooks.flakeModule
            ./pre-commit.nix
          ];
        };
    };
}
