{
  description = "Nix configuration for dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # Ollama pin (temporary):
    # - Avoids ggml/glibc crash (GGML_ASSERT(prev != ggml_uncaught_exception)) seen with ollama 0.11.7 on NixOS/glibc 2.40
    # - This input is used only to source a known-good ollama package for the user service
    # - To remove later: delete this input and the pinned import in home/vscode.nix, then rebuild
    nixpkgs-ollama.url = "github:nixos/nixpkgs/0e209ec10915826c36bd0518251fd664967cbb9e";
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
        (import ./flakeModules/pre-commit { inherit inputs; })
      ];

      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            inputsFrom = [ config.pre-commit-defaults.devShell ];
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
