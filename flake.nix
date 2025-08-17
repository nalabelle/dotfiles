{
  description = "Nix configuration for dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
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
  };
  outputs =
    inputs@{ nixpkgs, ... }:
    let
      libFunctions = import ./lib { inherit inputs; };
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Darwin Configs
      darwinConfigurations.tennyson = libFunctions.mkDarwinSystem { hostname = "tennyson"; };
      # Test target to ensure home-manager config works when testing on darwin
      homeConfigurations."nalabelle@darwin" = libFunctions.mkHomeConfig {
        hostname = "default";
        system = "aarch64-darwin";
      };

      # NixOS Configs
      nixosConfigurations.chandler = libFunctions.mkNixOSSystem {
        hostname = "chandler";
        system = "x86_64-linux";
      };

      # Home Manager Configs
      homeConfigurations."nalabelle@twain" = libFunctions.mkHomeConfig {
        hostname = "twain";
        system = "x86_64-linux";
      };

      # Packages
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          fetch-mcp-server = import ./packages/fetch-mcp-server.nix { inherit pkgs; };
        }
      );

      # Development shell - import from shell.nix
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = import ./shell.nix { inherit pkgs; };
        }
      );
    };
}
