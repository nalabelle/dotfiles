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
    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, home-manager, nixpkgs, darwin, mkAlias, ... }:
    let
      # Variables used in flake
      vars = { username = "nalabelle"; };
    in {
      # Linux configurations
      nixosConfigurations = (import ./hosts {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs home-manager darwin vars;
      });

      # macOS configurations
      darwinConfigurations = (import ./darwin {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs home-manager darwin mkAlias vars;
      });

      # Home Manager configurations
      homeConfigurations = (import ./nix {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs home-manager vars;
      });
    };
}
