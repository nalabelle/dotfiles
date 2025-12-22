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
    pre-commit-module = {
      url = "path:./flakeModules/pre-commit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      libFunctions = import ./lib { inherit inputs; };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      imports = [
        inputs.pre-commit-module.flakeModule
      ];

      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            inputsFrom = [ config.devShells.pre-commit ];
            buildInputs = with pkgs; [
              nixd
            ];
            shellHook = ''
              echo "Dev environment loaded."
            '';
          };
        };
      flake = {
        # Export flake modules for external consumption
        flakeModules.pre-commit = inputs.pre-commit-module.flakeModule;

        # Darwin Configs
        darwinConfigurations.tennyson = libFunctions.mkDarwinSystem { hostname = "tennyson"; };
        homeConfigurations."nalabelle@chandler" = libFunctions.mkHomeConfig {
          # Chandler (Linux server) home-manager config
          # Bootstrap: nix run nixpkgs#home-manager -- switch --flake .#nalabelle@chandler
          hostname = "chandler";
          system = "x86_64-linux";
        };
        homeConfigurations."nalabelle@doyle" = libFunctions.mkHomeConfig {
          # Bootstrap: nix run nixpkgs#home-manager -- switch --flake .#nalabelle@doyle
          hostname = "chandler";
          system = "x86_64-linux";
        };
        homeConfigurations."nalabelle@darwin" = libFunctions.mkHomeConfig {
          # Test target to ensure home-manager config works when testing on darwin
          hostname = "default";
          system = "aarch64-darwin";
        };
        homeConfigurations.nalabelle = libFunctions.mkHomeConfig {
          # Generic home-manager config target
          hostname = "default";
          system = "aarch64-darwin";
        };
        homeConfigurations."nalabelle@linux" = libFunctions.mkHomeConfig {
          # Linux home-manager config target for testing
          hostname = "default";
          system = "x86_64-linux";
        };
      };
    };
}
