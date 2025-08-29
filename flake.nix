{
  description = "Nix configuration for dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    opnix = {
      url = "github:brizzbuzz/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mkAlias = {
      url = "github:cdmistman/mkAlias";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, git-hooks, ... }:
    let
      libFunctions = import ./lib { inherit inputs; };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flakeModules/pre-commit
      ];
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixd
            ];
            shellHook = ''
              ${config.preCommitShellHook}
              echo "Dev environment loaded."
            '';
          };
          packages.fetch-mcp-server = pkgs.callPackage ./packages/fetch-mcp-server.nix {
            inherit pkgs;
          };
        };
      flake = {
        # Export flake modules for external consumption
        flakeModules.pre-commit = ./flakeModules/pre-commit;

        # NixOS Configs
        nixosConfigurations.chandler = libFunctions.mkNixOSSystem {
          hostname = "chandler";
          system = "x86_64-linux";
        };
        # Darwin Configs
        darwinConfigurations.tennyson = libFunctions.mkDarwinSystem { hostname = "tennyson"; };
        homeConfigurations."nalabelle@darwin" = libFunctions.mkHomeConfig {
          # Test target to ensure home-manager config works when testing on darwin
          hostname = "default";
          system = "aarch64-darwin";
        };
        # Home Manager Configs
        homeConfigurations."nalabelle@twain" = libFunctions.mkHomeConfig {
          hostname = "twain";
          system = "x86_64-linux";
        };
      };
    };
}
