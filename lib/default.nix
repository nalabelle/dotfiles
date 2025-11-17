{ inputs, ... }:
let
  username = "nalabelle";
  nixpkgsConfig = {
    allowUnfree = true;
  };

  # Create a darwin configuration for a host
  mkDarwinSystem =
    { hostname }:
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        inputs.opnix.darwinModules.default
        ../nix/common.nix
        ../nix/darwin.nix
        ../hosts/${hostname}/darwin-configuration.nix
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs username hostname; };
          home-manager.users.${username} = {
            imports = [
              inputs.opnix.homeManagerModules.default
              ./opnix-templates.nix
              ../home
              (
                if builtins.pathExists ../hosts/${hostname}/home-configuration.nix then
                  ../hosts/${hostname}/home-configuration.nix
                else
                  { }
              )
            ];
          };
        }
      ];
      specialArgs = { inherit inputs username hostname; };
    };

  # Create a standalone home configuration
  mkHomeConfig =
    { hostname, system }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = nixpkgsConfig;
      };
      modules = [
        inputs.opnix.homeManagerModules.default
        {
          home.username = username;
          home.homeDirectory =
            if system == "aarch64-darwin" then "/Users/${username}" else "/home/${username}";
        }
        ./opnix-templates.nix
        ../home
        (
          if builtins.pathExists ../hosts/${hostname}/home-configuration.nix then
            ../hosts/${hostname}/home-configuration.nix
          else
            { }
        )
      ];
      extraSpecialArgs = { inherit inputs; };
    };

in
{
  # Export the functions directly for explicit configuration
  inherit mkDarwinSystem mkHomeConfig;
}
