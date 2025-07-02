{ inputs, ... }:
let
  systems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
  lib = inputs.nixpkgs.lib;
  username = "nalabelle";
  nixpkgsConfig = { allowUnfree = true; };

  # Create a darwin configuration for a host
  mkDarwinSystem = { hostname }:
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ../nix/nixos.nix
        ../nix/darwin.nix
        ../hosts/${hostname}/darwin-configuration.nix
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
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
  __functor = _: _args:
    let
      # Get all hosts from the hosts directory
      hostsDir = ../hosts;
      entries = builtins.readDir hostsDir;
      hosts = builtins.attrNames
        (lib.filterAttrs (_: type: type == "directory") entries);

      # Create darwin configurations for hosts with darwin-configuration.nix
      darwinConfigs = lib.listToAttrs (lib.filter (x: x != null) (map (hostname:
        if builtins.pathExists
        ../hosts/${hostname}/darwin-configuration.nix then {
          name = hostname;
          value = mkDarwinSystem { inherit hostname; };
        } else
          null) hosts));

      # Create home configurations for all hosts with home-configuration.nix
      hostHomeConfigs = lib.listToAttrs (lib.filter (x: x != null) (map
        (hostname:
          if builtins.pathExists
          ../hosts/${hostname}/home-configuration.nix then {
            name = "${username}@${hostname}";
            value = mkHomeConfig {
              inherit hostname;
              system = if builtins.pathExists
              ../hosts/${hostname}/darwin-configuration.nix then
                "aarch64-darwin"
              else
                "x86_64-linux";
            };
          } else
            null) hosts));

      # Create system-specific packages
      mkSystemPackages = system:
        let
          homeConfig = mkHomeConfig {
            hostname = "default";
            inherit system;
          };
        in { homeConfigurations."${username}" = homeConfig; };

    in {
      darwinConfigurations = darwinConfigs;
      homeConfigurations = hostHomeConfigs;
      packages = lib.genAttrs systems mkSystemPackages;
    };
}
