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
        ../nix/darwin.nix
        ../hosts/${hostname}/darwin-configuration.nix
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs username hostname;
            isDarwin = true;
            isLinux = false;
          };
          home-manager.users.${username} = {
            imports = [
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
      specialArgs = {
        inherit inputs username hostname;
        isDarwin = true;
        isLinux = false;
      };
    };

  # Create a standalone home configuration
  mkHomeConfig =
    { hostname, system }:
    let
      isDarwin = builtins.match "^.*-darwin$" system != null;
      isLinux = !isDarwin;
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = nixpkgsConfig;
      };
      modules = [
        {
          home.username = username;
          home.homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
        }
        ../home
        (
          if builtins.pathExists ../hosts/${hostname}/home-configuration.nix then
            ../hosts/${hostname}/home-configuration.nix
          else
            { }
        )
      ];
      extraSpecialArgs = {
        inherit inputs isDarwin isLinux;
        inherit (inputs) nix-flatpak;
      };
    };

in
{
  # Export the functions directly for explicit configuration
  inherit mkDarwinSystem mkHomeConfig;
}
