{
  description = "Nix configuration for dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
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
  outputs = inputs:
    let libFunctions = import ./lib { inherit inputs; };
    in {
      # Darwin Configs
      darwinConfigurations.tennyson =
        libFunctions.mkDarwinSystem { hostname = "tennyson"; };
      # Test target to ensure home-manager config works when testing on darwin
      homeConfigurations."nalabelle@darwin" = libFunctions.mkHomeConfig {
        hostname = "default";
        system = "aarch64-darwin";
      };

      # Home Manager Configs
      homeConfigurations."nalabelle@twain" = libFunctions.mkHomeConfig {
        hostname = "twain";
        system = "x86_64-linux";
      };
    };
}
