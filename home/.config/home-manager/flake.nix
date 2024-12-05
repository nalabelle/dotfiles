{
  description = "Nix configuration for dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs }:
    let
      config = {
        x86_64-linux = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          modules = [
            ./home.nix
            {
              home.homeDirectory = "/home/nalabelle";
            }
          ];
        };
        aarch64-darwin = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "aarch64-darwin"; };
          modules = [
            ./osx.nix
            ./home.nix
            {
              home.homeDirectory = "/Users/nalabelle";
            }
          ];
        };
      };
    in {
      packages.aarch64-darwin.homeConfigurations.nalabelle = config.aarch64-darwin;
      packages.x86_64-linux.homeConfigurations.nalabelle = config.x86_64-linux;
    };
}
