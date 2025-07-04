{ inputs, ... }:
let
  systems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
  lib = inputs.nixpkgs.lib;
  username = "nalabelle";
  nixpkgsConfig = {
    allowUnfree = true;
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];
  };

  # Create a darwin configuration for a host
  mkDarwinSystem = { hostname }:
   inputs.nix-darwin.lib.darwinSystem {
     system = "aarch64-darwin";
     modules = [
        ../nix/common.nix
        ../nix/darwin.nix
        ../hosts/${hostname}/darwin-configuration.nix
        inputs.home-manager.darwinModules.home-manager
        {
          nixpkgs.overlays = [
            inputs.nix-vscode-extensions.overlays.default
          ];
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = {
            imports = [
              ../home
              (if builtins.pathExists ../hosts/${hostname}/home-configuration.nix then
                ../hosts/${hostname}/home-configuration.nix
              else
                { })
            ];
          };
        }
      ];
      specialArgs = { inherit inputs username hostname; };
    };

  # Create a standalone home configuration
  mkHomeConfig = { hostname, system }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = nixpkgsConfig;
      };
      modules = [
        {
          home.username = username;
          home.homeDirectory = if system == "aarch64-darwin" then
            "/Users/${username}"
          else
            "/home/${username}";
          nixpkgs.overlays = [
            inputs.nix-vscode-extensions.overlays.default
          ];
        }
        ../home
        (if builtins.pathExists ../hosts/${hostname}/home-configuration.nix then
          ../hosts/${hostname}/home-configuration.nix
        else
          { })
      ];
      extraSpecialArgs = { inherit inputs; };
    };

in {
  # Export the functions directly for explicit configuration
  inherit mkDarwinSystem mkHomeConfig;
}
